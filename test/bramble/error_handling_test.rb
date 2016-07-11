require "test_helper"

describe Bramble::ErrorHandling do
  module UnhandledErrorTest
    extend self

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
  end

  module HandledErrorTest
    extend UnhandledErrorTest
    ERRORS = []

    module_function

    def on_error(error)
      if error.message =~ /77/
        raise(error)
      else
        ERRORS << error
      end
    end
  end

  before do
    HandledErrorTest::ERRORS.clear
  end

  it "rescues from errors in .map" do
    items = [1,1,99,4,4]
    Bramble.map_reduce("error_test", HandledErrorTest, items)
    assert_equal({1 => 2, 4 => 8}, get_data_for_handle("error_test"))
    assert_equal ["Map: 99"], HandledErrorTest::ERRORS.map(&:message)
  end

  it "rescues from errors in .reduce" do
    items = [1,1,88,4,4]
    Bramble.map_reduce("error_test", HandledErrorTest, items)
    assert_equal({1 => 2, 4 => 8}, get_data_for_handle("error_test"))
    assert_equal ["Reduce: 88"], HandledErrorTest::ERRORS.map(&:message)
  end

  it "can re-raise errors from .on_error" do
    items = [1,1,77,4,4]
    error = assert_raises { Bramble.map_reduce("error_test", HandledErrorTest, items) }
    assert_equal "Reraise: 77", error.message
  end

  it "re-raises if there's no handler" do
    items = [1,1,99,4,4]
    error = assert_raises { Bramble.map_reduce("error_test", UnhandledErrorTest, items) }
    assert_equal "Map: 99", error.message

    items = [1,1,88,4,4]
    error = assert_raises { Bramble.map_reduce("error_test", UnhandledErrorTest, items) }
    assert_equal "Reduce: 88", error.message
  end
end
