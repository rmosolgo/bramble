require "test_helper"

describe Bramble::Map do
  before do
    Bramble.config.storage = Bramble::Storage::RedisStorage
  end

  module Sum
    JOB_IDS = []
    def self.job_id
      JOB_IDS.shift || raise("No more job_ids")
    end

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
    Sum::JOB_IDS << "x" << "y"
    Bramble.map_reduce("sum", Sum, [1,2,3])
    assert_equal({1 => 1, 2 => 2, 3 => 3}, get_data_for_handle("sum"))
    Bramble.map_reduce("sum", Sum, [1,2,3,2,2])
    assert_equal({1 => 1, 2 => 6, 3 => 3}, get_data_for_handle("sum"))

    # The old job is cleared, the new job is still there:
    assert_equal(nil, Bramble.config.storage.get(Bramble::Keys.total_count_key("sum:x")))
    assert_equal("y", Bramble.config.storage.get(Bramble::Keys.job_id_key("sum")))
    assert_equal("5", Bramble.config.storage.get(Bramble::Keys.total_count_key("sum:y")))
  end

  it "cancels one job if it gets started twice" do
    Sum::JOB_IDS << "x1" << "y1"
    handle = "sum"
    threads = [
      Thread.new { sleep 0.1; Bramble.map_reduce(handle, Sum, [1,2,3]) },
      Thread.new { sleep 0.2; Bramble.map_reduce(handle, Sum, [10,20,30]) },
    ]
    threads.map(&:join)
    assert_equal({10 => 10, 20 => 20, 30 => 30}, get_data_for_handle(handle))
  end
end
