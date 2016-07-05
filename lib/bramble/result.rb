module Bramble
  # This class exposes the data and some info about the state of the task
  class Result

    attr_reader :handle, :percent_mapped, :percent_reduced, :finished_at

    # Read the state for `handle` and store it in this object
    # The state for `handle` may change during this time, but you won't
    # see the changes until you get a new result.
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

    # @return [Hash<Any, Any>] The `key => value` results of `.reduce`
    def data
      @data ||= begin
        key = Bramble::Keys.result_key(handle)
        results = storage.reduce_result_get(key)
        Bramble::Serialize.load(results)
      end
    end

    # @return [Boolean] True if all data has been mapped and reduced
    def finished?
      # Possible to be greater than 1 because of floating-point arithmetic
      percent_finished >= 1
    end

    # @return [Boolean] True if the job has been started but it isn't finished yet
    def running?
      started? && !finished?
    end

    # How far along is this job?
    # `.map` is considered 50%, `.reduce` is considered 50%
    # @return [Float] Percent progress for this job
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
