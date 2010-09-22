require 'optparse'

module Kite

  # Parse the command line for configuration options needed
  # to run the Kite rack service.
  def self.cli_config(argv=nil)
    config = {}

    OptionsParser.new |opt|
      opt.on('--url', '-u URL') do |url|
        config[:url] = url
      end

      opt.on('--store', '-s STORE', 'storage adpater, eg. s3') do |store|
        config[:store] = store.to_sym
      end

      opt.on('--author', '-a NAME') do |title|
        config[:title] = title
      end

      opt.on('--title', '-t TITLE') do |title|
        config[:title] = title
      end

      opt.on('--index', '-i FILE') do |index|
        config[:index] = index
      end

      opt.on('--public', '-p PATH') do |path|
        config[:static] = path
      end

      opt.on('--cache', '-c SECONDS') do |seconds|
        config[:cache] = seconds.to_i
      end

      opt.on('--mode', '-m MODE', 'production, test or development') do |mode|
        config[:env] = mode.to_sym
      end

      opt.on('--config-file', '-f PATH', 'use this configuration file') do |file|
        data = YAML.load(File.new(file))
        config.update(data)
      end

      opt
    end

    parser.parse!(argv || ARGV)

    config[:root] = argv.unshift || Dir.pwd

    return config
  end

end
