require 'pathname'
#require 'kite/config'
#require 'kite/site'
require 'kite/rack'
require 'kite/storage_adapters/s3'

module Kite

  #
  class App

    # Root directory of local site.
    attr :root

    # Configuration.
    attr :config

    # Remote store (eg. S3).
    attr :store

    # Site controller.
    attr :site

    # Server (Rack).
    attr :server

    #
    def initialize(options={})
      @config = load_config    
      @config[:store] = :s3

      #@site   = Site.new(store, config)
      #@server = Rack.new(site)
    end

    #
    def builder
      Rack::Builder.new do
        run Kite::Rack, config
      end
    end

    #
    def domain
      config[:domain]
    end

    #
    def run
      server.run
    end

    #
    def load_config
      if config_file
        config = {}
        YAML.load(File.new(config_file)).each do |k,v|
          config[k.to_sym] = v
        end
        config
      else
        config = {}
      end
    end

    #
    def config_file
      @config_file ||= Dir[File.join(root, 'config.{yml,yaml}')].first
    end

  end

end

