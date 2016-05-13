require "bramble"
require "minitest/autorun"
require "minitest/focus"
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
Minitest::Spec.make_my_diffs_pretty!
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


def get_data_for_handle(handle)
  Bramble.get(handle).data
end
