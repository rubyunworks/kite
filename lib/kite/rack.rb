require 'rack'
require 'digest'

module Kite

  # = Rack Middleware
  #
  class Rack

    #
    DEFAULTS = {
      :author => ENV['USER'], # site author
      :title  => Dir.pwd.split('/').last, # site title
      :root   => Dir.pwd,
      :index  => "index.html", # site index
      :static => "public",
      :url    => "http://127.0.0.1",
      :cache  => 28800, # cache duration (seconds)
      :env    => "development"
    }

    # Configuration.
    attr :config

    #
    def initialize(app, config={})
      @app    = app
      @config = DEFAULTS.merge(config)
    end
 
    #
    def call(env)
      @request  = Rack::Request.new(env)
      @response = Rack::Response.new
 
      #return [400, {}, []] unless @request.get?
      return @app.call(env) unless @request.get? # or post?
 
      route = @request.path_info.sub(/^\//, '')

      response = go(route)

      if response
        @response.body = [response[:body]]
        @response['Content-Length'] = response[:body].length.to_s unless response[:body].empty?
        @response['Content-Type'] = Rack::Mime.mime_type(".#{response[:type]}")
   
        # Set http cache headers
        @response['Cache-Control'] = if config[:env] == 'production'
          "public, max-age=#{config[:cache]}"
        else
          "no-cache, must-revalidate"
        end
   
        @response['Etag'] = Digest::SHA1.hexdigest(response[:body])
   
        @response.status = response[:status]
        @response.finish
      else
        @app.call(env)
      end
    end

    #
    def go(route)
      route = config[:index] if route == ""
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
      return nil
      #return :body => http(404).first, :type => :html, :status => 404
    else
      return :body => body || "", :type => type, :status => status || 200
    end

    def root
      @root ||= Pathname.new(config[:root])
    end

    def local
      @local ||= root + (config[:static]
    end

    def store
      @store ||= storage_adpater.new(config)
    end

    def storage_adapter
      @storage_adapter ||= lookup_storage_adapter
    end

    #
    #def run
    #  system('rackup')
    #  #app.run!
    #end

    #
    #def app
    #  server = self
    #  Rack::Builder.new do
    #    use Rack::Reloader, 0
    #    use Rack::ContentLength
    #    run server
    #  end.to_app
    #end

  private

    def lookup_storage_adapter
      name = config[:store].upcase
      Kite.const_get(name)
    end

  end

end

