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
