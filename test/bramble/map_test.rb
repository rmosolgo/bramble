require "test_helper"

describe Bramble::Map do
  before do
    Bramble.config.storage = Bramble::Storage::RedisStorage
  end

  module Sum
    def self.items(provided_items)
      provided_items
    end

    def self.map(number)
      sleep 0.2 # Make it seem like a long-running task
      yield(number, number)
    end

    def self.reduce(zero, numbers)
      numbers.reduce(&:+)
    end
  end

  it "processes stuff" do
    Bramble.map_reduce("sum", Sum, [1,2,3], job_id: "x")
    assert_equal({1 => 1, 2 => 2, 3 => 3}, get_data_for_handle("sum"))
    Bramble.map_reduce("sum", Sum, [1,2,3,2,2], job_id: "y")
    assert_equal({1 => 1, 2 => 6, 3 => 3}, get_data_for_handle("sum"))
  end

  it "cancels one job if it gets started twice" do
    handle = "sum"
    threads = [
      Thread.new { sleep 0.1; Bramble.map_reduce(handle, Sum, [1,2,3]) },
      Thread.new { sleep 0.2; Bramble.map_reduce(handle, Sum, [10,20,30]) },
    ]
    threads.map(&:join)
    assert_equal({10 => 10, 20 => 20, 30 => 30}, get_data_for_handle(handle))
  end
end
