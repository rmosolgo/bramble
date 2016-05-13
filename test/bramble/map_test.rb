require "test_helper"

describe Bramble::Map do
  before do
    Bramble.config.storage = Bramble::Storage::RedisStorage
  end

  module Sum
    def self.map(number)
      yield(0, number)
    end

    def self.reduce(zero, numbers)
      numbers.reduce(&:+)
    end
  end

  it "processes stuff" do
    Bramble::Map.perform("sum", Sum, [1,2,3,4])
    assert_equal({"0" => 10}, Bramble.read("sum"))
    Bramble::Map.perform("sum", Sum, [1,2,3,4,5])
    assert_equal({"0" => 15}, Bramble.read("sum"))
  end
end
