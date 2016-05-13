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
      if Bramble::State.running?(handle)
        raw_values = storage.map_result_get(data_key(handle, raw_key))
        values = Bramble::Serialize.load(raw_values)
        key = Bramble::Serialize.load(raw_key)
        reduced_value = implementation.reduce(key, values)
        Bramble::State.running?(handle) do
          storage.reduce_result_set(result_key(handle), raw_key, Bramble::Serialize.dump(reduced_value))
          storage.increment(reduce_finished_count_key(handle))
        end
      else
        Bramble::State.clear_reduce(handle)
      end
    end

    private

    module_function

    def storage
      Bramble::Storage
    end
  end
end
