require "test_helper"

describe Bramble::Result do
  module LongRunning
    module_function

    def items(arg)
      sleep 2
      [:A, :B, :C]
    end

    def map(sym)
      yield(sym, sym)
    end

    def reduce(sym, syms)
      sym
    end
  end

  it "checks for running? / finished?" do
    handle = "long_running"
    thread = Thread.new { Bramble.map_reduce(handle, LongRunning) }
    sleep 0.5
    res_1 = Bramble.get(handle)
    assert_equal true, res_1.running?
    assert_equal false, res_1.finished?
    assert_equal({}, res_1.data)

    wait_for_handle(handle)

    res_2 = Bramble.get(handle)
    assert_equal false, res_2.running?
    assert_equal true, res_2.finished?
    assert_equal({A: :A, B: :B, C: :C}, res_2.data)
  end
end
