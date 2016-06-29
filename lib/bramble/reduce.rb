module Bramble
  module Reduce
    extend Bramble::Keys

    module_function

    def perform(handle, implementation)
      Bramble::State.running?(handle) do
        # Set how many reduce call we expect
        all_raw_keys = storage.map_keys_get(keys_key(handle))
        storage.set(reduce_total_count_key(handle), all_raw_keys.length)
        # Enqueue a job for each reduce call
        all_raw_keys.each do |raw_key|
          Bramble::ReduceJob.perform_later(handle, implementation.name, raw_key)
        end
      end
    end

    def perform_reduce(handle, implementation, raw_key)
      if Bramble::State.running?(handle)
        raw_values = storage.map_result_get(data_key(handle, raw_key))
        values = Bramble::Serialize.load(raw_values)
        key = Bramble::Serialize.load(raw_key)
        reduced_value = nil

        Bramble::ErrorHandling.rescuing(implementation) do
          # Run the defined .reduce function
          reduced_value = implementation.reduce(key, values)
          # Store the result
          Bramble::State.running?(handle) do
            storage.reduce_result_set(result_key(handle), raw_key, Bramble::Serialize.dump(reduced_value))
          end
        end

        # Mark this key as reduced, check if we're finished
        Bramble::State.running?(handle) do
          storage.increment(reduce_finished_count_key(handle))
          if Bramble::State.percent_reduced(handle) >= 1
            storage.set(finished_at_key(handle), Time.now.to_i)
          end
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
