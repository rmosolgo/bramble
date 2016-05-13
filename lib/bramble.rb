require "ostruct"
require "active_job"
require "bramble/keys"
require "bramble/map"
require "bramble/map_job"
require "bramble/reduce"
require "bramble/reduce_job"
require "bramble/storage"
require "bramble/version"
require "bramble/conf"

module Bramble
  def self.config
    if block_given?
      yield(Bramble::CONF)
    else
      Bramble::CONF
    end
  end

  # @param handle [String] This string will be used to store the result
  # @param implementation [#map, #reduce, #name] The container of map and reduce methods
  # @param items [Array] List of items to map over
  def self.map_reduce(handle, implementation, items)
    Bramble::Map.perform(handle, implementation, items)
  end

  # Get results for `handle`, if they exist
  def self.read(handle)
    Bramble::Storage.read(handle)
  end

  # Remove results for `handle`, if there are any
  def self.delete(handle)
    Bramble::Storage.delete(handle)
  end
end
