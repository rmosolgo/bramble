module Bramble
  class MapJob < ActiveJob::Base
    queue_as { Bramble.config.queue_as }
    def perform(handle, mapper_name, value)
      mapper = mapper_name.constantize
      Bramble::Map.perform_map(handle, mapper, value)
    end
  end
end
