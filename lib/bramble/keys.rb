module Bramble
  module Keys
    def namespace(handle)
      "#{Bramble.config.namespace}:#{handle}"
    end

    def data_key(handle, key)
      "#{namespace(handle)}:data:#{key}"
    end

    def keys_key(handle)
      "#{namespace(handle)}:keys"
    end

    def finished_count_key(handle)
      "#{namespace(handle)}:finished_count"
    end

    def total_count_key(handle)
      "#{namespace(handle)}:total_count"
    end

    def result_key(handle)
      "#{namespace(handle)}:result"
    end
  end
end
