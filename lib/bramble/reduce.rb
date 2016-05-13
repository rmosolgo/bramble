module Bramble
  module Reduce
    extend Bramble::Keys

    module_function

    def perform(handle, implementation)
      all_raw_keys = storage.map_keys_get(keys_key(handle))
      all_raw_keys.each do |raw_key|
        Bramble::ReduceJob.perform_later(handle, implementation.name, raw_key)
      end
    end

    def perform_reduce(handle, implementation, raw_key)
      values = storage.map_result_get(data_key(handle, raw_key))
      values = Bramble::Storage.load(values)
      reduced_value = implementation.reduce(Bramble::Storage.load(raw_key), values)
      storage.reduce_result_set(result_key(handle), raw_key, Bramble::Storage.dump(reduced_value))
    end

    private

    module_function

    def storage
      Bramble.config.storage
    end
  end
end
