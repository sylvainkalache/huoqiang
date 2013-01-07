require File.join(File.dirname(__FILE__),'logger.rb')

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
    def get_ip_location(ip, timeout = 7)
      Geocoder::Configuration.cache = Redis.new
      begin
        where = Geocoder.search(ip)
      rescue StandardError => e
        @logger.error "[Geocoder]#{e.message}"
      end

      unless where.empty?
        return where.first
      else
        false
      end
    end

    # Checking if the data parsed are valid
    #
    # @param [String] Proxy IP address
    # @param [Integer] Proxy port
    # @param [Boolean]
    def check_data_format(ip, port)
      # \d* one or several number
      # \. dot
      if ip =~ /^\d*\.\d*\.\d*\.\d*$/ and port.to_s =~ /^(\d+)*$/ and port.to_i.between?(1, 65535)
        return true
      else
        return false
      end
    end

  end
end