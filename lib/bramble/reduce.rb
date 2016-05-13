module Bramble
  module Reduce
    extend Bramble::Keys

    module_function

    def perform(handle, implementation)
      all_keys = storage.map_keys_get(keys_key(handle))
      all_keys.each do |key|
        Bramble::ReduceJob.perform_later(handle, implementation.name, key)
      end
    end

    def perform_reduce(handle, implementation, value_key)
      values = storage.map_result_get(data_key(handle, value_key))
      values = values.map { |v| Bramble::Storage.load(v) }
      reduced_value = implementation.reduce(value_key, values)
      storage.reduce_result_set(result_key(handle), value_key, Bramble::Storage.dump(reduced_value))
    end

    private

    module_function

    def storage
      Bramble.config.storage
    end
  end
end
