require 'fileutils'
require 'optparse'
require 'rack/server'
require 'rack/handler'
require 'rack/builder'
#require 'rack/directory'
#require 'rack/file'

module Kite

  #
  class Server < ::Rack::Server

    # Parse the command line for configuration options needed
    # to run the Kite rack server.
    class Options
      def parse!(args)
        args, options = args.dup, {}

        opt_parser = OptionParser.new do |opts|
          opts.banner = "Usage: brite-server [options]"

          opts.on("-p", "--port=port", Integer,
                  "Runs server on the specified port.", "Default: 3000") { |v| options[:Port] = v }

          opts.on("-b", "--binding=ip", String,
                  "Binds server to the specified ip.", "Default: 0.0.0.0") { |v| options[:Host] = v }

          opts.on("-d", "--daemon", "Make server run as a Daemon.") { options[:daemonize] = true }

          opts.on("-u", "--debugger", "Enable ruby-debugging for the server.") { options[:debugger] = true }

          opts.on("-e", "--environment=name", String,
                  "Specifies the environment to run this server under (test/development/production).",
                  "Default: development") do |v|
            options[:environment] = v
          end

          opts.on("-u", "--rackup=file", String, "Use custom rackup configuration.") do |v|
            options[:rackup] = v
          end

          opts.separator ""

          opt.on('--url', '-u URL') do |url|
            config[:url] = url
          end

          opt.on('--store', '-s STORE', 'storage adpater, eg. s3') do |store|
            config[:store] = store.to_sym
          end

          #opt.on('--author', '-a NAME') do |title|
          #  config[:author] = author
          #end

          #opt.on('--title', '-t TITLE') do |title|
          #  config[:title] = title
          #end

          opt.on('--index', '-i FILE', 'Default: index.html') do |index|
            options[:index] = index
          end

          opt.on('--public', '-p PATH') do |path|
            options[:static] = path
          end

          opt.on('--cache', '-c SECONDS') do |seconds|
            options[:cache] = seconds.to_i
          end

          #opt.on('--mode', '-m MODE', 'production, test or development') do |mode|
          #  options[:env] = mode.to_sym
          #end

          opt.on('-f', '--config-file PATH', 'Use configuration file.') do |file|
            data = YAML.load(File.new(file))
            options.update(data)
          end

          opts.separator ""

          opts.on_tail("-h", "--help", "Show this help message.") { puts opts; exit }
        end

        opt_parser.parse!(args)

        # TODO: what is this for? what about :root?
        options[:server] = args.shift

        return options
      end
    end

    #
    def initialize(*)
      super
      set_environment
    end

    #
    def opt_parser
      Options.new
    end

    #
    def set_environment
      ENV["KITE_ENV"] ||= options[:environment]
    end

    #
    def start
      puts "=> Booting #{server}"
      puts "=> On http://#{options[:Host]}:#{options[:Port]}"
      puts "=> Call with -d to detach" unless options[:daemonize]
      trap(:INT) { exit }
      puts "=> Ctrl-C to shutdown server" unless options[:daemonize]

      #Create required tmp directories if not found
      %w(cache pids sessions sockets).each do |dir_to_make|
        FileUtils.mkdir_p(File.join('.cache', dir_to_make))
      end

      super
    ensure
      # The '-h' option calls exit before @options is set.
      # If we call 'options' with it unset, we get double help banners.
      puts 'Exiting' unless @options && options[:daemonize]
    end

    def middleware
      middlewares = []
      #middlewares << [Rails::Rack::LogTailer, log_path] unless options[:daemonize]
      #middlewares << [Rails::Rack::Debugger]  if options[:debugger]
      Hash.new(middlewares)
    end

    def log_path
      ".cache/kite.log"
    end

    def default_options
      super.merge({
        :Port        => 3000,
        :environment => (ENV['KITE_ENV'] || "development").dup,
        :daemonize   => false,
        :debugger    => false,
        :pid         => ".cache/pids/server.pid",
        :config      => nil
      })
    end

    #
    def root
      Dir.pwd
    end

    def app
      @app ||= begin
        config_file = options[:rackup]
        if config_file && ::File.exist?(config_file)
          app, options = Rack::Builder.parse_file(config_file, opt_parser)
          self.options.merge!(options)
          app
        else
          root = self.root
          app, options = Rack::Builder.new do
            #run Rack::Directory.new("#{root}")
            run Kite::Rack.new(options)
          end
          #self.options.merge!(options)
          app
        end
      end
    end

  end

end

## The static content rooted in the current working directory
## Eg. Dir.pwd =&gt; http://0.0.0.0:3000/
#root = Dir.pwd
#puts ">>> Serving: #{root}"
#run Rack::Directory.new("#{root}")

