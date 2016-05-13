module Bramble
  # This exists to call `implementation.items` in the background.
  # It might take a long time to fetch, so let's background it.
  #
  # Then it starts the map-reduce job.
  class BeginJob < Bramble::BaseJob
    def perform(handle, job_id, implementation_name, items_options)
      implementation = implementation_name.constantize
      all_items = implementation.items(items_options)
      Bramble::Map.perform(handle, job_id, implementation, all_items)
    end
  end
end
