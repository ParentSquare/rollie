# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

module Rollie
  RSpec.describe RateLimiter do
    before do
      @r = described_class.new(SecureRandom.hex(8), count_blocked: true)
    end

    describe '#within_limit' do
      it 'requires a block' do
        expect { @r.within_limit }.to raise_error(ArgumentError)
      end

      it 'returns status' do
        status = @r.within_limit { true }
        expect(status.count).to eq(1)
        expect(status.exceeded?).to be(false)
        expect(status.time_remaining).to eq(1000)
      end

      it 'executes block only while within limit' do
        count = 0
        status = nil
        30.times do
          status = @r.within_limit do
            count += 1
          end
        end
        expect(count).to eq(25)
        expect(status.count).to eq(30)
        expect(status.exceeded?).to be(true)
      end

      it 'blocks all actions within the window' do
        @r = described_class.new(SecureRandom.hex(8), limit: 10, interval: 100, count_blocked: true)
        count = 0
        30.times do
          @r.within_limit do
            count += 1
          end
          sleep 0.004
        end
        expect(count).to eq(10)
      end

      it 'allows blocked actions not to be counted' do
        @r = described_class.new(SecureRandom.hex(8), limit: 10, interval: 100, count_blocked: false)
        count = 0
        30.times do
          @r.within_limit do
            count += 1
          end
          sleep 0.0045
        end
        expect(count).to eq(20)
      end
    end

    describe '#count' do
      it 'returns the current count' do
        30.times do
          @r.within_limit { ; sleep 0.001; }
        end

        expect(@r.count).to eq(30)

        @r = described_class.new(SecureRandom.hex(8), limit: 10, count_blocked: false)

        30.times do
          @r.within_limit { ; sleep 0.001; }
        end

        expect(@r.count).to eq(10)
      end
    end
  end
end
