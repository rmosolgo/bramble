module Bramble
  class MapJob < Bramble::BaseJob
    def perform(handle, mapper_name, raw_value)
      mapper = mapper_name.constantize
      value = Bramble::Serialize.load(raw_value)
      Bramble::Map.perform_map(handle, mapper, value)
    end
  end
end
