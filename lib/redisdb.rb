require 'redis'
module Huoqiang
  class Redisdb

    def initialize
      @redis = Redis.new()
      @logger = Huoqiang.logger('access')
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
        $logger.error "[Redis]Cannot get key #{key}"
        $logger.error "[Redis]Cannot connect to Redis: #{e.message}"
        return false
      end
    end

    # Get all the fields and values in a hash
    #
    # @param [String] key
    def hgetall(key)
      begin
        @redis.hgetall(key)
      rescue Redis::CannotConnectError => e
        $logger.error "[Redis]Cannot get key #{key}"
        $logger.error "[Redis]Cannot connect to Redis: #{e.message}"
        return false
      end
    end

    # Set the string value of a key
    #
    # @param [String] key
    # @param [String] value
    # @param [Integer] timeout Time after which the entry will expire
    #
    # @return [Boolean]
    def set(key, value, timeout = nil)
      begin
        @redis.set(key, value)
        @redis.expire(key, timeout) unless timeout.nil?
      rescue Redis::CannotConnectError => e
        $logger.error "[Redis]Cannot set key #{key}"
        $logger.error "[Redis]Cannot connect to Redis: #{e.message}"
        return false
      end
    end

    # Set multiple hash fields to multiple values
    #
    # @param [String] key
    # @paran [Hash] values
    # @param [Integer] timeout Time after which the entry will expire
    #
    # @return [Boolean]
    def hmset(key, values, timeout = nil)
      begin
        @redis.hmset(key, *values.to_a.flatten)
        @redis.expire(key, timeout) unless timeout.nil?
      rescue Redis::CannotConnectError => e
        $logger.error "[Redis]Cannot set key #{key}"
        $logger.error "[Redis]Cannot connect to Redis: #{e.message}"
        return false
      end
    end

  end
end