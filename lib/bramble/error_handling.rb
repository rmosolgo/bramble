module Bramble
  module ErrorHandling
    # If an error is raised during the block,
    # pass it to the implementation's `on_error` function.
    def self.rescuing(implementation)
      yield
    rescue StandardError => err
      if implementation.respond_to?(:on_error)
        implementation.on_error(err)
      else
        raise(err)
      end
    end
  end
end
