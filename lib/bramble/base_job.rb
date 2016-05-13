module Bramble
  class BaseJob < ActiveJob::Base
    queue_as { Bramble.config.queue_as }
  end
end
