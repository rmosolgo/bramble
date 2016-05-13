module Bramble
  class ReduceJob < ActiveJob::Base
    queue_as { Bramble.config.queue_as }
    def perform(handle, reducer_name, key)
      reducer = reducer_name.constantize
      Bramble::Reduce.perform_reduce(handle, reducer, key)
    end
  end
end
