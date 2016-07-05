module Bramble
  module Map
    extend Bramble::Keys

    module_function

    # For each of `values`, queue up a job to call the map function
    def perform(handle, implementation, values)
      Bramble::State.running?(handle) do
        storage.set(map_total_count_key(handle), values.length)
        values.each do |value|
          Bramble::MapJob.perform_later(handle, implementation.name, Bramble::Serialize.dump(value))
        end
      end
    end

    # Call `.map` on `value`, storing the result for `.reduce` and handling any error.
    def perform_map(handle, implementation, value)
      Bramble::State.running?(handle) do
        impl_keys_key = keys_key(handle)

        Bramble::ErrorHandling.rescuing(implementation) do
          # Execute the provided map function
          implementation.map(value) do |map_key, map_val|
            Bramble::State.running?(handle) do
              raw_key = Bramble::Serialize.dump(map_key)
              raw_value = Bramble::Serialize.dump(map_val)
              # Push the result to be reduced
              storage.map_keys_push(impl_keys_key, raw_key)
              storage.map_result_push(data_key(handle, raw_key), raw_value)
            end
          end
        end

        # Mark this item as mapped (even if there was an error)
        Bramble::State.running?(handle) do
          finished = storage.increment(map_finished_count_key(handle))
          total = storage.get(map_total_count_key(handle)).to_i
          if finished == total
            Bramble::Reduce.perform(handle, implementation)
          end
        end
      end
    end

    private

    module_function

    def storage
      Bramble::Storage
    end
  end
end
