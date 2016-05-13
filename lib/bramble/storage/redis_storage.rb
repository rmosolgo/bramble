module Bramble
  module Storage
    module RedisStorage
      module_function

      def set(key, value)
        redis_conn.set(key, value)
      end

      def get(key)
        redis_conn.get(key)
      end

      def delete(key)
        redis_conn.del(key)
      end

      def increment(key)
        redis_conn.incr(key)
      end

      def map_result_push(key, value)
        redis_conn.rpush(key, value)
      end

      def map_result_get(key)
        redis_conn.lrange(key, 0, -1)
      end

      def reduce_result_set(storage_key, reduce_key, value)
        redis_conn.hset(storage_key, reduce_key, value)
      end

      def reduce_result_get(storage_key)
        redis_conn.hgetall(storage_key)
      end

      def map_keys_push(key, value)
        redis_conn.sadd(key, value)
      end

      def map_keys_get(key)
        redis_conn.smembers(key)
      end

      private

      module_function

      def redis_conn
        Bramble.config.redis_conn
      end
    end
  end
end
