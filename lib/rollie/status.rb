module Rollie
  class Status
    attr_accessor :time_remaining, :count

    def initialize(time_remaining, count, exceeded)
      @time_remaining = time_remaining
      @count = count
      @exceeded = exceeded
    end

    def exceeded?
      @exceeded
    end
  end
end
