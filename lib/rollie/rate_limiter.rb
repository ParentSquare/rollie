# frozen_string_literal: true

module Rollie
  class RateLimiter
    # Create a new RateLimiter instance.
    #
    # @param [String] key A unique name to track this rate limit against.
    # @option options [Integer] :limit The limit
    # @option options [Integer] :interval The interval in milliseconds for this rate limit
    # @option options [String] :namespace Optional namespace for this rate limit
    # @option options [Boolean] :count_blocked if true, all calls to
    #   within_limit will count towards total execution count, even if blocked.
    #
    # @return [RateLimiter] RateLimiter instance
    def initialize(key, options = {})
      @key = "#{options[:namespace]}#{key}"
      @limit = options[:limit] || 25
      @interval = (options[:interval] || 1000) * 1000
      @count_blocked = options.key?(:count_blocked) ? options[:count_blocked] : false
    end

    # Executes a block as long as the current rate is within the limit.
    #
    # @return [Status] The current status for this RateLimiter.
    def within_limit
      raise ArgumentError, 'requires a block' unless block_given?

      Rollie.redis do |conn|
        status = inc(conn)
        unless status.exceeded?
          yield
        end
        status
      end
    end

    # Increase counter and let you decide what to do next. Will always count blocked
    #
    # @return [Status] The current status for this RateLimiter.
    def increase_counter
      Rollie.redis do |conn|
        inc(conn, true)
      end
    end

    # @return [Integer] The current count of this RateLimiter.
    def count
      Rollie.redis do |conn|
        range = conn.zrange(@key, 0, -1)
        range.length
      end
    end

    private

    def inc(conn, count_blocked = nil)
      count_blocked = count_blocked.nil? ? @count_blocked : count_blocked
      time = (Time.now.to_r * 1_000_000).round
      old = time - @interval
      range = conn.multi do
        conn.zremrangebyscore(@key, 0, old)
        conn.zadd(@key, time, time)
        conn.zrange(@key, 0, -1)
        conn.expire(@key, (@interval / 1_000_000.0).ceil)
      end[2]

      exceeded = range.length > @limit
      current_count = range.length
      time_remaining = range.first.to_i - time + @interval

      if exceeded && !count_blocked
        conn.zremrangebyscore(@key, time, time)
        current_count -= 1
      end

      Rollie::Status.new((time_remaining / 1000).floor, current_count, exceeded)
    end
  end
end
