require "test_helper"

describe Bramble::ErrorHandling do
  module ErrorTest
    ERRORS = []

    module_function

    def items(provided_items)
      provided_items
    end

    def map(item)
      if item == 99 # magic
        raise("Map: 99")
      elsif item == 77
        raise("Reraise: 77")
      else
        yield(item, item)
      end
    end

    def reduce(item, items)
      if item == 88 # magic
        raise("Reduce: 88")
      else
        items.reduce(&:+)
      end
    end

    def on_error(error)
      if error.message =~ /77/
        raise(error)
      else
        ERRORS << error
      end
    end
  end

  before do
    ErrorTest::ERRORS.clear
  end

  it "rescues from errors in .map" do
    items = [1,1,99,4,4]
    Bramble.map_reduce("error_test", ErrorTest, items)
    assert_equal({1 => 2, 4 => 8}, get_data_for_handle("error_test"))
    assert_equal ["Map: 99"], ErrorTest::ERRORS.map(&:message)
  end

  it "rescues from errors in .reduce" do
    items = [1,1,88,4,4]
    Bramble.map_reduce("error_test", ErrorTest, items)
    assert_equal({1 => 2, 4 => 8}, get_data_for_handle("error_test"))
    assert_equal ["Reduce: 88"], ErrorTest::ERRORS.map(&:message)
  end

  it "can re-raise errors from .on_error" do
    items = [1,1,77,4,4]
    error = assert_raises { Bramble.map_reduce("error_test", ErrorTest, items) }
    assert_equal "Reraise: 77", error.message
  end
end
