require "set"

module Bramble
  module Storage
    # ☠ This is for single-threaded, single-process Ruby only!
    # If you try to use this in production, you're going to have a bad time.
    module MemoryStorage
      STORAGE = {}

      module_function

      def transaction
        yield
      end

      def set(key, value)
        STORAGE[key] = value
      end

      def get(key)
        STORAGE[key]
      end

      def delete(key)
        STORAGE.delete(key)
      end

      def increment(key)
        STORAGE[key] ||= 0
        STORAGE[key] += 1
      end

      def map_result_push(key, value)
        STORAGE[key] ||= []
        STORAGE[key] << value
      end

      def map_result_get(key)
        STORAGE[key] || []
      end

      def reduce_result_set(storage_key, reduce_key, value)
        STORAGE[storage_key] ||= {}
        STORAGE[storage_key][reduce_key] = value
      end

      def reduce_result_get(storage_key)
        STORAGE[storage_key] || {}
      end

      def map_keys_push(key, value)
        STORAGE[key] ||= Set.new
        STORAGE[key] << value
      end

      def map_keys_get(key)
        STORAGE[key] || Set.new
      end
    end
  end
end
