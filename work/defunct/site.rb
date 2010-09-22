module Kite

  class Site

    #
    attr :store

    #
    attr :config

    #
    attr :root

    #
    def initialize(store, config)
      @store  = store
      @config = config
      @root   = Pathname.new(config.root)
      @local  = root + config.static
    end

    #
    def local
      @local
    end

    #
    def http(num)
      ""
    end

    #
    def go(route)
      route = config.index if route == ""
      type  = File.extname(route).sub(/^\./, '')
      if (local + route).file?
        body   = (local + route).read
        status = nil
      else
        body   = store[route].to_s
        status = nil
      end
      #return :body => body || "", :type => type, :status => status || 200
    rescue Errno::ENOENT => e
      return :body => http(404).first, :type => :html, :status => 404
    else
      return :body => body || "", :type => type, :status => status || 200
    end

  end

end
