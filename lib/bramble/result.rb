module Bramble
  # This class exposes the data and some info about the state of the task
  class Result

    attr_reader :handle, :percent_mapped, :percent_reduced, :finished_at

    def initialize(handle)
      job_id = storage.get(Bramble::Keys.job_id_key(handle))
      @handle = "#{handle}:#{job_id}"
      @percent_mapped = Bramble::State.percent_mapped(@handle)
      @percent_reduced = Bramble::State.percent_reduced(@handle)
      if finished?
        finished_at_ms = storage.get(Bramble::Keys.finished_at_key(@handle)).to_i
        @finished_at = Time.at(finished_at_ms)
      else
        @finished_at = nil
      end
    end

    def data
      @data ||= begin
        key = Bramble::Keys.result_key(handle)
        results = storage.reduce_result_get(key)
        Bramble::Serialize.load(results)
      end
    end

    def finished?
      # Possible to be greater than 1 because of floating-point arithmetic
      percent_finished >= 1
    end

    def running?
      started? && !finished?
    end

    def percent_finished
      (percent_mapped + percent_reduced) / 2
    end

    private

    def started?
      @started ||= !!storage.get(Bramble::Keys.status_key(handle))
    end

    def storage
      Bramble::Storage
    end
  end
end
