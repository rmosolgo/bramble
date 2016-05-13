require "test_helper"

describe Bramble::Storage do
  module Concat
    def self.map(array)
      yield(array.first, array)
    end

    def self.reduce(int, arrays)
      arrays.reduce(&:+)
    end
  end

  it "deletes entries by handle" do
    handle = "arrays"
    values = [[1,2,3], [2,3,4], [1,3,5], [2,2,2]]
    Bramble.map_reduce(handle, Concat, values)
    result = {
      1 => [1,2,3,1,3,5],
      2 => [2,3,4,2,2,2],
    }
    assert_equal(result, Bramble.read(handle))
    Bramble.delete(handle)
    assert_equal({}, Bramble.read(handle))
  end
end
