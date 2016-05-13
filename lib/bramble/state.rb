module Bramble
  module State
    extend Bramble::Keys
    SEPARATOR = ":"
    module_function

    # Run the block and return true if the `job_id` is still active
    def running?(handle)
      handle_name, job_id = handle.split(SEPARATOR)
      is_running = storage.get(job_id_key(handle_name)) == job_id
      if block_given?
        yield
      end
      is_running
    end

    def start_job(handle)
      handle_name, job_id = handle.split(SEPARATOR)
      previous_job_id = storage.get(job_id_key(handle_name))
      if previous_job_id
        clear_job("#{handle_name}:#{previous_job_id}")
      end
      storage.set(status_key(handle), "started")
      storage.set(job_id_key(handle_name), job_id)
    end

    def clear_job(handle)
      handle_name, job_id = handle.split(SEPARATOR)
      storage.delete(job_id_key(handle_name))
      storage.delete(status_key(handle))
      clear_reduce(handle)
      clear_map(handle)
    end

    def percent_mapped(handle)
      percent_between_keys(
        map_total_count_key(handle),
        map_finished_count_key(handle)
      )
    end

    def percent_reduced(handle)
      percent_between_keys(
        reduce_total_count_key(handle),
        reduce_finished_count_key(handle)
      )
    end

    def clear_map(handle)
      map_group_keys = storage.map_keys_get(keys_key(handle))
      map_group_keys.each do |group_key|
        storage.delete(data_key(handle, group_key))
      end
      storage.delete(keys_key(handle))
      storage.delete(map_total_count_key(handle))
      storage.delete(map_finished_count_key(handle))
    end

    def clear_reduce(handle)
      storage.delete(reduce_total_count_key(handle))
      storage.delete(reduce_finished_count_key(handle))
      storage.delete(result_key(handle))
    end

    private

    def self.storage
      Bramble::Storage
    end

    def self.percent_between_keys(total_key, finished_key)
      total = storage.get(total_key).to_f
      if total == 0
        0
      else
        finished = storage.get(finished_key).to_i
        finished / total
      end
    end
  end
end
