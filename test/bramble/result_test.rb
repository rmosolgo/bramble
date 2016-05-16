require "test_helper"

describe Bramble::Result do
  module LongRunning
    module_function

    def items(arg)
      sleep 1
      [:A, :B, :C, :C]
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
    assert_equal 0, res_1.percent_mapped
    assert_equal 0, res_1.percent_reduced
    assert_equal 0, res_1.percent_finished
    assert_equal nil, res_1.finished_at
    assert_equal({}, res_1.data)

    thread.join

    res_2 = Bramble.get(handle)
    assert_equal 1.0, res_2.percent_mapped
    assert_equal 1.0, res_2.percent_reduced
    assert_equal 1.0, res_2.percent_finished
    assert_equal false, res_2.running?
    assert_equal true, res_2.finished?
    assert_in_delta Time.now, res_2.finished_at, 1000, "Within the same second"
    assert_equal({"A" => "A", "B" => "B", "C" => "C"}, res_2.data)
  end
end
