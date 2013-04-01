require File.join(File.dirname(__FILE__),'logger.rb')
require 'geo_ip'

module Huoqiang
  class Data_tool

    def initialize
      @logger = Huoqiang.logger('crawler')
    end

    # Return geolocalisation information of the IP
    #
    # @param [String] ip IP address
    # @param [Integer] timeout Timeout for Geocoder to drop the request
    #
    # @return [Hash]
    def self.get_ip_location(ip)
      @logger = Huoqiang.logger('crawler')
      if Redisdb.is_entry_cached(ip)
        return eval(Redisdb.is_entry_cached(ip))
      else
        GeoIp.api_key = '9b913fdfdc39d20095af789b587f6156068987096033b59a758adb2f8a5663dd'
        begin
          where = GeoIp.geolocation(ip)

          # Don't overload the API
          sleep 5
        rescue StandardError => e
          @logger.error "Failed to get ip location: #{e.message}"
        end

        unless where.nil? || where.empty?
          # Caching the entry
          redis = Redisdb.new()
          redis.set(ip, where)

          return where
        else
          false
        end
      end
    end

    # Return city of the IP
    #
    # @param [String] ip
    #
    # @return [String] City's name
    def self.get_ip_city(ip)
      geo_ip = get_ip_location(ip)

      if geo_ip and geo_ip[:country_code] == 'CN'
        if geo_ip[:city].nil? or geo_ip[:city].empty?
          return 'Unknown'
        else
          return geo_ip[:city]
        end
      end
    end

    # Checking if the data is valid
    #
    # @param [String] Proxy IP address
    # @param [Integer] Proxy port
    # @param [Boolean]
    def self.check_data_format(ip, port)
      # \d* one or several number
      # \. dot
      if ip =~ /^\d*\.\d*\.\d*\.\d*$/

        if port.to_s =~ /^(\d+)*$/ and port.to_i.between?(1, 65535)
          return true
        else
          return false
        end
      else
        return false
      end
    end

  end
end
