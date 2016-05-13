require "ostruct"
require "active_job"
require "bramble/base_job"
require "bramble/begin_job"
require "bramble/keys"
require "bramble/map"
require "bramble/map_job"
require "bramble/reduce"
require "bramble/reduce_job"
require "bramble/result"
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
  # @param implementation [.map, .reduce, .name, .items(options)] The container of map and reduce methods
  # @param items_options [Object] will be passed to .items
  def self.map_reduce(handle, implementation, items_options = nil, job_id: nil)
    job_id ||= Time.now.strftime("%s%6N")
    Bramble::Storage.delete(handle)
    Bramble.config.storage.set(Bramble::Keys.status_key(handle), "started")
    Bramble.config.storage.set(Bramble::Keys.job_id_key(handle), job_id)
    Bramble::BeginJob.perform_later(handle, job_id, implementation.name, items_options)
  end

  # @return [Bramble::Result] Status & data for this handle
  def self.get(handle)
    Bramble::Result.new(handle)
  end

  # Remove results for `handle`, if there are any
  def self.delete(handle)
    Bramble::Storage.delete(handle)
  end
end
