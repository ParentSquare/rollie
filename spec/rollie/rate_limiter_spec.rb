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
        @r = described_class.new(SecureRandom.hex(8), limit: 10, interval: 3000, count_blocked: true)
        count = 0

        # T= 0, count=0
        5.times { @r.within_limit { count += 1 } }
        Timecop.travel(Time.now + 1)
        # T= +1, count=5
        5.times { @r.within_limit { count += 1 } }
        Timecop.travel(Time.now + 1)
        # T= +2, count=10
        5.times { @r.within_limit { count += 1 } }
        Timecop.travel(Time.now + 1)
        # The last 5 did not run since they were blocked
        # however, they counted towards the internal rate because of count_blocked=true
        expect(count).to eq(10)

        # T= +3, count=10
        5.times { @r.within_limit { count += 1 } }

        # So even though the first 5 dropped off, we can't run again
        # since the limiter still has 10 runs recorded in the interval range
        expect(count).to eq(10)
      end

      it 'allows blocked actions not to be counted' do
        @r = described_class.new(SecureRandom.hex(8), limit: 10, interval: 3000, count_blocked: false)
        count = 0

        # T= 0, count=0
        5.times { @r.within_limit { count += 1 } }
        Timecop.travel(Time.now + 1)
        # T= +1, count=5
        5.times { @r.within_limit { count += 1 } }
        Timecop.travel(Time.now + 1)
        # T= +2, count=10
        5.times { @r.within_limit { count += 1 } }
        Timecop.travel(Time.now + 1)
        # The last 5 did not run since they were blocked
        # but they were not counted towards the rate limit
        expect(count).to eq(10)

        # T= +3, count=10
        5.times { @r.within_limit { count += 1 } }

        # Since our last 5 did not count towards the rate limit, we can now
        # run another 5 since the first 5 dropped off the interval range
        expect(count).to eq(15)
      end
    end

    describe "#increase_counter" do
      before do
        @limiter = RateLimiter.new(SecureRandom.hex(8), count_blocked: false)
      end

      it "should return status" do
        status = @limiter.increase_counter
        expect(status.count).to eq(1)
        expect(status.exceeded?).to be(false)
        expect(status.time_remaining).to eq(1000)
      end

      it "should increase count regardless of count_blocked setting" do
        35.times do
          @limiter.increase_counter
        end

        status = @limiter.increase_counter
        expect(status.count).to eq(36)
        expect(status.exceeded?).to be(true)
      end
    end

    describe '#count' do
      it 'returns the current count' do
        30.times do
          @r.within_limit { true }
        end

        expect(@r.count).to eq(30)

        @r = described_class.new(SecureRandom.hex(8), limit: 10, count_blocked: false)

        30.times do
          @r.within_limit { true }
        end

        expect(@r.count).to eq(10)
      end
    end
  end
end
