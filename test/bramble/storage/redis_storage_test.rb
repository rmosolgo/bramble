require "test_helper"

describe Bramble::Storage::RedisStorage do
  before do
    Bramble.config.storage = Bramble::Storage::RedisStorage
  end

  module CountLetters
    def self.items(provided_items)
      provided_items
    end

    def self.map(word)
      word.upcase.each_char { |char| char != " ".freeze && yield(char, 1) }
    end

    def self.reduce(letter, observations)
      observations.length
    end
  end

  it "stores results" do
    Bramble.map_reduce("berries", CountLetters, ["Blackberry", "Raspberry"])
    Bramble.map_reduce("vines", CountLetters, ["Poison Ivy", "English Ivy", "Virginia Creeper"])

    berries = {
      "R"=>5,
      "B"=>3,
      "E"=>2,
      "A"=>2,
      "Y"=>2,
      "L"=>1,
      "P"=>1,
      "S"=>1,
      "K"=>1,
      "C"=>1,
    }

    vines = {
      "I"=>7,
      "E"=>4,
      "V"=>3,
      "R"=>3,
      "N"=>3,
      "G"=>2,
      "P"=>2,
      "S"=>2,
      "O"=>2,
      "Y"=>2,
      "C"=>1,
      "L"=>1,
      "A"=>1,
      "H"=>1,
    }

    assert_equal(berries, get_data_for_handle("berries"))
    assert_equal(vines, get_data_for_handle("vines"))
    assert_equal({}, get_data_for_handle("nonsense"))
  end

  it "sets results to expire in 1 day" do
    Bramble.map_reduce("greens", CountLetters, ["Spinach", "Arugula"])

    res = Bramble.get("greens")
    redis_key = "Bramble:#{res.handle}:result"
    time_to_live = Bramble.config.redis_conn.ttl(redis_key)
    one_day_in_seconds = 60 * 60 * 24
    assert_in_delta(one_day_in_seconds, time_to_live, 2)
  end

  it "clears all data" do
    Bramble.map_reduce("greens", CountLetters, ["Spinach", "Arugula"])
    assert Bramble.config.redis_conn.keys("Bramble*").count > 0
    Bramble.delete_all
    assert Bramble.config.redis_conn.keys("Bramble*").count == 0
  end
end
