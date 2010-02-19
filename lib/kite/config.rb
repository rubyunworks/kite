module Kite

  class Config

    #
    DEFAULTS = {
      'author' => ENV['USER'], # blog author
      'title'  => Dir.pwd.split('/').last, # site title
      #'root'   => "index",
      'index'  => "index.html", # site index
      'static' => "public",
      'url'    => "http://127.0.0.1",
      'cache'  => 28800, # cache duration (seconds)
      'env'    => "development"
    }

    #
    def initialize(root)
      @data = {}
      @data['root'] = root.to_s
      @data.update DEFAULTS
      @data.update YAML.load(File.new(config_file)) if config_file
    end

    #
    def method_missing(s, *a)
      @data[s.to_s]
    end

  private

    #
    def config_file
      @config_file ||= Dir[File.join(root, 'config.{yml,yaml}')].first
    end

  end

end

