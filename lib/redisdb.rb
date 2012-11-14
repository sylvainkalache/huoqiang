require 'redis'
module Huoqiang
  class Redisdb

    def initialize
      @redis = Redis.new()
    end

    # Get the value of a key
    #
    # @param [String] key Key to get value from
    #
    # @return [String]
    def get(key)
      begin
        @redis.get(key)
      rescue Redis::CannotConnectError => e
        $logger.error "Cannot get key #{key}"
        $logger.error "Cannot connect to Redis - #{e.message}"
        return false
      end
    end

    # Set the string value of a key
    #
    # @param [String] key
    # @param [String] value
    # @param [Integer] timeout Time after which the key will expire
    #
    # @return [Boolean]
    def set(key, value, timeout = nil)
      begin
        @redis.set(key, value)
        @redis.expire(key, timeout) unless value.nil?
      rescue Redis::CannotConnectError => e
        $logger.error "Cannot set key #{key}"
        $logger.error "Cannot connect to Redis - #{e.message}"
        return false
      end
    end

  end
end