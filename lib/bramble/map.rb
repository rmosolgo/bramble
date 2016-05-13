module Bramble
  module Map
    extend Bramble::Keys

    module_function

    def perform(handle, implementation, values)
      # TODO: make sure there isn't one going on right now
      Bramble::Storage.delete(handle)
      storage.set(total_count_key(handle), values.length)
      values.each do |value|
        Bramble::MapJob.perform_later(handle, implementation.name, value)
      end
    end

    def perform_map(handle, implementation, value)
      impl_keys_key = keys_key(handle)
      implementation.map(value) do |map_key, map_val|
        raw_key = Bramble::Storage.dump(map_key)
        storage.map_keys_push(impl_keys_key, raw_key)
        storage.map_result_push(data_key(handle, raw_key), Bramble::Storage.dump(map_val))
      end
      finished = storage.increment(finished_count_key(handle))
      total = storage.get(total_count_key(handle)).to_i
      if finished == total
        Bramble::Reduce.perform(handle, implementation)
      end
    end

    private

    module_function

    def storage
      Bramble.config.storage
    end
  end
end
