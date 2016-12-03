module Rollie

  class RateLimiter

    def initialize(key, options = {})
      @key = "#{options[:namespace]}#{key}"
      @limit = options[:limit] || 25
      @interval = (options[:interval] || 1000) * 1000
    end

    def within_limit
      raise ArgumentError, "requires a block" unless block_given?

      Rollie.redis do |conn|
        status = inc(conn)
        unless status.exceeded?
          yield
        end
        status
      end
    end

    private

    def inc(conn)
      time = (Time.now.to_r * 1000000).round
      old = time - @interval
      range = conn.multi do
        conn.zremrangebyscore(@key, 0, old)
        conn.zadd(@key, time, time)
        conn.zrange(@key, 0, -1)
        conn.expire(@key, (@interval / 1000000).ceil)
      end[2]

      exceeded = range.length > @limit
      time_remaining = range.first.to_i - time + @interval
      current_count = exceeded ? @limit : range.length
      Rollie::Status.new((time_remaining / 1000).floor, current_count, exceeded)
    end

  end
end
