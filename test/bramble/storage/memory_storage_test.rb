require "test_helper"

describe Bramble::Storage::MemoryStorage do
  before do
    Bramble.config.storage = Bramble::Storage::MemoryStorage
  end

  after do
    Bramble.config.storage = Bramble::Storage::RedisStorage
  end

  module BigSmallSort
    module_function

    def items(provided_items)
      provided_items
    end

    def map(value)
      if value < 100
        yield("small", value)
      else
        yield("big", value)
      end
    end

    def reduce(size, values)
      values.reduce(&:+)
    end
  end

  it "stores results" do
    Bramble.map_reduce("sort_1", BigSmallSort, [5, 500, 95, 105])
    Bramble.map_reduce("sort_2", BigSmallSort, [6, 600, 96, 106])
    assert_equal({"big" => 605, "small" => 100}, get_data_for_handle("sort_1"))
    assert_equal({"big" => 706, "small" => 102}, get_data_for_handle("sort_2"))
    Bramble.delete("sort_1")
    Bramble.delete("sort_2")
    assert_equal({}, get_data_for_handle("sort_1"))
    assert_equal({}, get_data_for_handle("sort_2"))
  end
end
