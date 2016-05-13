require "bramble/storage/redis_storage"
require "bramble/storage/memory_storage"

module Bramble
  module Storage
    extend Bramble::Keys

    def self.read(handle)
      key = result_key(handle)
      results = Bramble.config.storage.reduce_result_get(key)
      results.reduce({}) do |memo, (key, str_val)|
        memo[key] = load(str_val)
        memo
      end
    end

    def self.load(str)
      Marshal.load(str)
    end

    def self.dump(obj)
      Marshal.dump(obj)
    end
  end
end
