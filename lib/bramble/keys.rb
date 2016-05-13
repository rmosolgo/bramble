module Bramble
  module Keys
    module_function

    def namespace(handle)
      "#{Bramble.config.namespace}:#{handle}"
    end

    def data_key(handle, key)
      "#{namespace(handle)}:data:#{key}"
    end

    def keys_key(handle)
      "#{namespace(handle)}:keys"
    end

    def map_finished_count_key(handle)
      "#{namespace(handle)}:map_finished_count"
    end

    def reduce_finished_count_key(handle)
      "#{namespace(handle)}:reduce_finished_count"
    end

    def total_count_key(handle)
      "#{namespace(handle)}:total_count"
    end

    def result_key(handle)
      "#{namespace(handle)}:result"
    end

    def job_id_key(handle)
      "#{namespace(handle)}:job_id"
    end

    def status_key(handle)
      "#{namespace(handle)}:status"
    end
  end
end
