module Kite

  # Config is simply a hash with some convenience methods
  # for Kite configuration.
  class Config < Hash

    #
    DEFAULTS = {
      :author  => ENV['USER'], # site author
      :title   => Dir.pwd.split('/').last, # site title
      :root    => Dir.pwd,
      :index   => "index.html", # site index
      :static  => "public",
      :url     => "http://127.0.0.1",
      :cache   => 28800, # cache duration (seconds)
      :mode    => "development"
    }

    def self.file(file)
      config = YAML.load(File.new(file))
      new config
    end

    #
    def initialize(config={})
      update(DEFAULTS)
      update(rekey(config))
    end

    #
    def method_missing(s, *a)
      self[s.to_sym]
    end

    private

    #
    #def config_file
    #  @config_file ||= Dir[File.join(root, 'config.{yml,yaml}')].first
    #end


    def rekey(hash)
      hash.inject({}){ |h, (k,v)| h[k.to_sym] = v; h }
    end

  end

end

