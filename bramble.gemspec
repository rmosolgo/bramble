require File.expand_path("../lib/bramble/version", __FILE__)
Gem::Specification.new do |s|
  s.name = "bramble"
  s.version = Bramble::VERSION
  s.summary = "Map-reduce, backed by ActiveJob"
  s.description = "Distribute map-reduce tasks with ActiveJob, storing the results in Redis (or another backend)"
  s.author = "Robert Mosolgo"
  s.email = "rdmosolgo@gmail.com"
  s.homepage = "https://github.com/rmosolgo/bramble"
  s.license = "MIT"
  s.required_ruby_version = ">= 2.0.0"
  s.files = Dir["{lib}/**/*", "README.md"]
  s.require_path = "lib"

  s.add_runtime_dependency "activejob"
  s.add_development_dependency "minitest"
  s.add_development_dependency "minitest-focus"
  s.add_development_dependency "minitest-reporters"
  s.add_development_dependency "rake"
  s.add_development_dependency "redis"
end
