# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Rollie do
  describe '.redis' do
    it 'requires a block' do
      expect { described_class.redis }.to raise_error(ArgumentError)
    end

    it 'returns a Redis instance from the pool' do
      described_class.redis do |conn|
        expect(conn.class).to eq(Redis::Namespace)
      end
    end
  end

  describe '.redis=' do
    it 'allows hash options to initialize connection pool' do
      options = { url: 'redis://foo' }
      expect(Rollie::RedisPool).to receive(:create).with(options)
      described_class.redis = options
    end

    it 'allows a connection pool' do
      pool = ConnectionPool.new { true }
      described_class.redis = pool
      expect(described_class.redis_pool).to eq(pool)
    end
  end
end
