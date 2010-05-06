require 'pathname'
require 'kite/config'
require 'kite/site'
require 'kite/s3'
require 'kite/rack'

module Kite

  #--
  # TODO: Rename to Session ?
  #++
  class Application

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
    def initialize(root=Dir.pwd)
      @root   = Pathname.new(root)
      @config = Config.new(root)
      @store  = S3.new(domain)
      @site   = Site.new(store, config)
      @server = Rack.new(site)
    end

    #
    def domain
      config.domain
    end

    #
    def run
      server.run
    end

  end

end

