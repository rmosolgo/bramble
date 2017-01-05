module Bramble
  CONF = OpenStruct.new(
    redis_conn: nil,
    expire_after: 60 * 60 * 24,
    namespace: "Bramble",
    queue_as: :bramble,
    storage: Bramble::Storage::RedisStorage
  )
end
