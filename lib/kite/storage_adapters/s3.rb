module Kite

  require 'aws/s3'

  # Amazon s3 interface
  class S3

    include Enumerable

    # Bucket name.
    attr_accessor :bucket

    # 
    attr_accessor :access_key

    attr_accessor :secret_key

    #
    # TODO: Use a generic name for `bucket` that will work across storage adapters.
    def initialize(config={})
      self.bucket     = config[:bucket] || config[:domain]
      self.access_key = config[:aws_access_key_id]     || ENV['AWS_ACCESS_KEY_ID']
      self.secret_key = config[:aws_secret_access_key] || ENV['AWS_SECRET_ACCESS_KEY']
      connect
    end

    # File configuration.
    #--
    # TODO: Use XDG
    #++
    def config
      @config ||= (
        file = File.expand_path("~/.s3conf/s3config.yml")
        if File.exist?(file)
          YAML.load(File.new(file))
        else
          {}
        end
      )
    end

    #
    def connect
      AWS::S3::Base.establish_connection!(
        :access_key_id     => access_key,
        :secret_access_key => secret_key
      )
      @store = AWS::S3::Bucket.find(bucket)
      return self
    end

    #
    def store
      @store
    end

    #
    def [](name)
      object = store[name]
      object ? object.value : nil
    end

    #
    def each(&block)
      store(&block)
    end

    # Simple file sync. Synchronizes s3 bucket with a given directory.
    #
    # TODO: Don't shell out; rubify this code. Would like to depend on
    # s3sync.rb but that code needs to APIized better first.
    def sync(dir, opts={})
      dir = dir.chomp('/') + '/'
      opts = opts.map do |k, v|
        case v
        when true
          "--#{k}"
        else
          "--#{k} #{v}"
        end
      end
      cmd = "s3sync #{opts} -r #{dir} #{bucket}:"
      puts cmd if $DEBUG
      system(cmd)
    end

  end

end

