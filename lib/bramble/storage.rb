require "forwardable"
require "bramble/storage/redis_storage"
require "bramble/storage/memory_storage"

module Bramble
  # A single access point to the storage selected by `Bramble.config.storage`.
  # All methods are delegated to that storage adapter
  module Storage
    extend SingleForwardable

    def_delegators :storage_instance,
      :set, :get, :delete, :increment,
      :map_result_push, :map_result_get,
      :reduce_result_set, :reduce_result_get,
      :map_keys_push, :map_keys_get

    private

    def self.storage_instance
      Bramble.config.storage
    end
  end
end
