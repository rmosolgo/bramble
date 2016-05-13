require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "test" << "lib"
  t.pattern = "test/**/*_test.rb"
  t.warning = false
end

task(default: :test)
