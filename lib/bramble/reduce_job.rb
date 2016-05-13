module Bramble
  class ReduceJob < Bramble::BaseJob
    def perform(handle, implementation_name, key)
      implementation = implementation_name.constantize
      Bramble::Reduce.perform_reduce(handle, implementation, key)
    end
  end
end
