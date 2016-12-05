require "spec_helper"

describe Rollie do

  describe :redis do

    it "should require a block" do
      expect{ Rollie.redis }.to raise_error(ArgumentError)
    end

    it "should return a Redis instance from the pool" do
      Rollie.redis do |conn|
        expect(conn.class).to eq(Redis::Namespace)
      end
    end

  end

  describe :redis= do

    it "should allow hash options to initialize connection pool" do
      options = {url: "redis://foo"}
      pool = ConnectionPool.new do; end
      expect(Rollie::RedisPool).to receive(:create).with(options).and_return(pool)
      Rollie.redis = options
    end

    it "should allow a connection pool" do
      pool = ConnectionPool.new do; end
      Rollie.redis = pool
      expect(Rollie.redis_pool).to eq(pool)
    end

  end

end
