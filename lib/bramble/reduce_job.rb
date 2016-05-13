module Bramble
  class ReduceJob < Bramble::BaseJob
    def perform(handle, job_id, implementation_name, key)
      implementation = implementation_name.constantize
      Bramble::Reduce.perform_reduce(handle, job_id, implementation, key)
    end
  end
end
