require "test_helper"

describe Bramble::Map do
  before do
    Bramble.config.storage = Bramble::Storage::RedisStorage
  end

  module Sum
    def self.map(number)
      yield(number, number)
    end

    def self.reduce(zero, numbers)
      numbers.reduce(&:+)
    end
  end

  it "processes stuff" do
    t = Thread.new {
      Bramble::Map.perform("sum", Sum, [1,2,3])
    }
    t.join
    assert_equal({1 => 1, 2 => 2, 3 => 3}, Bramble.read("sum"))
    Bramble::Map.perform("sum", Sum, [1,2,3,2,2])
    assert_equal({1 => 1, 2 => 6, 3 => 3}, Bramble.read("sum"))
  end
end
