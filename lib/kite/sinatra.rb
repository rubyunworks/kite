module Kite

  require 'sinatra/base'
  require 'kite/s3'

  # Sintra-based controller.
  # 
  # This mostly works, but has an issue with mime types (eg. css come out wrong).
  # Howver, this is being replaced by a pure Rack back end, so it may be deprecated
  # rather then improved.
  class Sinatra < Sinatra::Base

    #
    def self.root=(dir)
      $root = dir
    end

    #
    def self.domain=(uri)
      @domain = uri
    end

    #
    set :config, Proc.new {
      YAML.load(File.new(File.join($root, 'config.yml')))
    }

    #
    set :s3config, Proc.new {
      YAML.load(File.new(File.expand_path("~/.s3config/s3config.yml")))
    }

    #
    set :store, Proc.new {
      Kite::S3.new do |s3|
        s3.bucket     = config['domain']
        s3.access_key = s3config['aws_access_key_id']     || ENV['AWS_ACCESS_KEY_ID']
        s3.secret_key = s3config['aws_secret_access_key'] || ENV['AWS_SECRET_ACCESS_KEY']
      end
    }

    # Any local static files to serve.
    # These have priority over the S3 bucket.
    set :public, Proc.new {
      File.join($root, "public")
    }

    # This before filter ensures that your pages are only ever served
    # once (per deploy) by Sinatra, and then by Varnish after that.
    before do
      response.headers['Cache-Control'] = 'public, max-age=31557600' # 1 year
    end

    #
    get '/' do
      options.store['index.html']
    end

    #
    get '/*' do
      key = params["splat"].first
      #key.gsub!('/', '--')
      options.store[key]
    end

  end

end

