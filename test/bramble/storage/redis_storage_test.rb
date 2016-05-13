require "test_helper"

describe Bramble::Storage::RedisStorage do
  before do
    Bramble.config.storage = Bramble::Storage::RedisStorage
  end

  module CountLetters
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

    assert_equal(berries, Bramble.read("berries"))
    assert_equal(vines, Bramble.read("vines"))
    assert_equal({}, Bramble.read("nonsense"))
  end
end
