module Bramble
  # This is the parent class for all Bramble jobs.
  # It sets the queue based on your config.
  class BaseJob < ActiveJob::Base
    queue_as { Bramble.config.queue_as }
  end
end
