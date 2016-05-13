module Bramble
  module Map
    extend Bramble::Keys

    module_function

    def perform(handle, implementation, values)
      # TODO: make sure there isn't one going on right now
      clear_previous(handle)
      storage.set(total_count_key(handle), values.length)
      values.each do |value|
        Bramble::MapJob.perform_later(handle, implementation.name, value)
      end
    end

    def perform_map(handle, implementation, value)
      impl_keys_key = keys_key(handle)
      implementation.map(value) do |map_key, map_val|
        storage.map_keys_push(impl_keys_key, map_key)
        storage.map_result_push(data_key(handle, map_key), Bramble::Storage.dump(map_val))
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

    def clear_previous(handle)
      # Reset counts
      storage.set(total_count_key(handle), 0)
      storage.set(finished_count_key(handle), 0)
      storage.delete(result_key(handle))

      # Clear any dangling data
      data_keys = storage.map_keys_get(keys_key(handle))
      data_keys.each do |value_key|
        storage.delete(data_key(handle, value_key))
      end
      storage.delete(keys_key(handle))
    end
  end
end
