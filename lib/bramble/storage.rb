require "bramble/storage/redis_storage"
require "bramble/storage/memory_storage"

module Bramble
  module Storage
    extend Bramble::Keys

    def self.read(handle)
      key = result_key(handle)
      results = storage.reduce_result_get(key)
      load(results)
    end

    # Wipe out the results for this handle
    def self.delete(handle)
      # Reset counts
      storage.delete(total_count_key(handle))
      storage.delete(finished_count_key(handle))
      # Reset result
      storage.delete(result_key(handle))

      # Reset dangling map data
      map_group_keys = storage.map_keys_get(keys_key(handle))
      map_group_keys.each do |group_key|
        storage.delete(data_key(handle, group_key))
      end
      storage.delete(keys_key(handle))
    end


    # prepare an object for storage
    def self.dump(obj)
      Marshal.dump(obj)
    end

    # reload an object from storage
    def self.load(stored_obj)
      case stored_obj
      when Array
        stored_obj.map { |obj| load(obj) }
      when Hash
        stored_obj.inject({}) do |memo, (k, v)|
          memo[load(k)] = load(v)
          memo
        end
      else
        Marshal.load(stored_obj)
      end
    end

    private

    def self.storage
      Bramble.config.storage
    end
  end
end
