require "redis"

Bramble.config do |conf|
  conf.redis_conn = Redis.new
end
