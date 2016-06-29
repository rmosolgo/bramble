module Bramble
  module ErrorHandling
    # If an error is raised during the block,
    # pass it to the implementation's `on_error` function.
    def self.rescuing(implementation)
      yield
    rescue StandardError => err
      implementation.on_error(err)
    end
  end
end
