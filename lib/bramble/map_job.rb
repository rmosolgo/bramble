module Bramble
  class MapJob < Bramble::BaseJob
    def perform(handle, job_id, mapper_name, raw_value)
      mapper = mapper_name.constantize
      value = Bramble::Storage.load(raw_value)
      Bramble::Map.perform_map(handle, job_id, mapper, value)
    end
  end
end
