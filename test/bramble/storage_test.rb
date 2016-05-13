require "test_helper"

describe Bramble::Storage do
  module Concat
    def self.items(provided_items)
      provided_items
    end

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
    assert_equal(result, get_data_for_handle(handle))
    Bramble.delete(handle)
    assert_equal({}, get_data_for_handle(handle))
  end
end
