module Bramble
  module Storage
    module RedisStorage
      module_function

      def set(key, value)
        redis_send(:set, key, value)
      end

      def get(key)
        redis_send(:get, key)
      end

      def delete(key)
        redis_send(:del, key)
      end

      def increment(key)
        redis_send(:incr, key)
      end

      def map_result_push(key, value)
        redis_send(:rpush, key, value)
      end

      def map_result_get(key)
        redis_send(:lrange, key, 0, -1)
      end

      def reduce_result_set(storage_key, reduce_key, value)
        redis_send(:hset, storage_key, reduce_key, value)
      end

      def reduce_result_get(storage_key)
        redis_send(:hgetall, storage_key)
      end

      def map_keys_push(key, value)
        redis_send(:sadd, key, value)
      end

      def map_keys_get(key)
        redis_send(:smembers, key)
      end

      def delete_all
        all_keys = redis_conn.keys("#{Bramble.config.namespace}*")
        redis_conn.del(*all_keys)
      end

      private

      module_function

      def redis_conn
        Bramble.config.redis_conn
      end

      ONE_DAY_IN_SECONDS = 60 * 60 * 24
      def redis_send(operation, key, *args)
        res = redis_conn.public_send(operation, key, *args)
        redis_conn.expire(key, ONE_DAY_IN_SECONDS)
        res
      end
    end
  end
end
