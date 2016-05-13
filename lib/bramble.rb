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
require "bramble/serialize"
require "bramble/state"
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
  def self.map_reduce(handle, implementation, items_options = {})
    # Secret feature: the implementation can provide a job_id
    job_id = if implementation.respond_to?(:job_id)
      implementation.job_id
    else
      Time.now.strftime("%s%6N")
    end
    handle = "#{handle}:#{job_id}"
    Bramble::State.start_job(handle)
    Bramble::BeginJob.perform_later(handle, implementation.name, items_options)
  end

  # @return [Bramble::Result] Status & data for this handle
  def self.get(handle)
    Bramble::Result.new(handle)
  end

  # Remove results for `handle`, if there are any
  def self.delete(handle)
    Bramble::State.clear_job(handle)
  end
end
