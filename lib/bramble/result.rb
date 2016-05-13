module Bramble
  # This class exposes the data and some info about the state of the task
  class Result

    attr_reader :handle

    def initialize(handle)
      @handle = handle
    end

    def data
      @data ||= Bramble::Storage.read(handle)
    end

    def finished?
      @finished ||= finished_count > 0 && total_count == finished_count
    end

    def running?
      @running ||= started? && !finished?
    end

    private

    def total_count
      @total_count ||= storage.get(Bramble::Keys.total_count_key(handle)).to_i
    end

    def finished_count
      @finished_count ||= storage.get(Bramble::Keys.reduce_finished_count_key(handle)).to_i
    end

    def started?
      @started ||= !!storage.get(Bramble::Keys.status_key(handle))
    end

    def storage
      Bramble.config.storage
    end
  end
end
