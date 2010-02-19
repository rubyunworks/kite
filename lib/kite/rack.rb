module Kite

  #
  class RackServer

    require 'rack'
    require 'digest'

    # Site controller.
    attr :site

    # Configuration.
    attr :config
 
    #
    def initialize(site, config={}, &blk)
      @site   = site
      @config = config.is_a?(Config) ? config : Config.new(config)
      @config.instance_eval(&blk) if block_given?
    end
 
    #
    def call(env)
      @request = Rack::Request.new(env)
      @response = Rack::Response.new
 
      return [400, {}, []] unless @request.get?
 
      route = @request.path_info.sub(/^\//, '')

      response = site.go(route)

      @response.body = [response[:body]]
      @response['Content-Length'] = response[:body].length.to_s unless response[:body].empty?
      @response['Content-Type'] = Rack::Mime.mime_type(".#{response[:type]}")
 
      # Set http cache headers
      @response['Cache-Control'] = if config.env == 'production'
        "public, max-age=#{config.cache}"
      else
        "no-cache, must-revalidate"
      end
 
      @response['Etag'] = Digest::SHA1.hexdigest(response[:body])
 
      @response.status = response[:status]
      @response.finish
    end

    #
    def run
      system('rackup')
      #app.run!
    end

    #
    #def app
    #  server = self
    #  Rack::Builder.new do
    #    use Rack::Reloader, 0
    #    use Rack::ContentLength
    #    run server
    #  end.to_app
    #end

  end

end

