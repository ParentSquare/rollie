# frozen_string_literal: true

require 'connection_pool'
require 'redis'
require 'redis-namespace'

module Rollie
  class RedisPool
    class << self
      def create(options = {})
        pool_size = options[:pool_size] || 5
        pool_timeout = options[:pool_timeout] || 1

        ConnectionPool.new(timeout: pool_timeout, size: pool_size) do
          build_client(options)
        end
      end

      private

      def build_client(options)
        namespace = options[:namespace] || 'Rollie'
        client = Redis.new redis_options(options)
        Redis::Namespace.new(namespace, redis: client)
      end

      def redis_options(options)
        redis = options.dup
        redis[:url] ||= ENV.fetch('REDIS_URL', nil)
        redis[:driver] ||= 'ruby'
        redis.delete(:namespace)
        redis
      end
    end
  end
end
