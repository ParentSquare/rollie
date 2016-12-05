require "rollie/rate_limiter"
require "rollie/redis_pool"
require "rollie/status"
require "rollie/version"

module Rollie
  class << self

    def redis
      raise ArgumentError, "requires a block" unless block_given?
      redis_pool.with do |conn|
        yield(conn)
      end
    end

    # Configures the redis connection pool. Options can be a hash of redis connection pool options or a pre-configured
    # ConnectionPool instance.
    #
    # @option options [String] :url The redis connection URL
    # @option options [String] :driver The redis driver
    # @option options [Integer] :pool_size Size of the connection pool
    # @option options [Integer] :pool_timeout Pool timeout in seconds
    # @option options [String] :namespace Optional namespace for redis keys
    def redis=(options)
      @redis_pool = if options.is_a?(ConnectionPool)
        options
       else
        Rollie::RedisPool.create(options)
       end
    end

    def redis_pool
      @redis_pool ||= Rollie::RedisPool.create
    end

  end
end
