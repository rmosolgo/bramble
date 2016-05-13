module Bramble
  CONF = OpenStruct.new(
    redis_conn: nil,
    namespace: "Bramble",
    queue_as: :bramble,
    storage: Bramble::Storage::RedisStorage
  )
end
