module Bramble
  module Map
    extend Bramble::Keys

    module_function

    def perform(handle, job_id, implementation, values)
      Bramble::Storage.if_running(handle, job_id) do
        storage.set(total_count_key(handle), values.length)
        values.each do |value|
          Bramble::MapJob.perform_later(handle, job_id, implementation.name, Bramble::Storage.dump(value))
        end
      end
    end

    def perform_map(handle, job_id, implementation, value)
      Bramble::Storage.if_running(handle, job_id) do
        impl_keys_key = keys_key(handle)
        implementation.map(value) do |map_key, map_val|
          Bramble::Storage.if_running(handle, job_id) do
            raw_key = Bramble::Storage.dump(map_key)
            storage.map_keys_push(impl_keys_key, raw_key)
            storage.map_result_push(data_key(handle, raw_key), Bramble::Storage.dump(map_val))
          end
        end
        Bramble::Storage.if_running(handle, job_id) do
          finished = storage.increment(map_finished_count_key(handle))
          total = storage.get(total_count_key(handle)).to_i
          if finished == total
            Bramble::Reduce.perform(handle, job_id, implementation)
            Bramble::Storage.clean_map_data(handle)
          end
        end
      end
    end

    private

    module_function

    def storage
      Bramble.config.storage
    end
  end
end
