module Huoqiang
  class Data_tool
    # Return the country of the IP
    #
    # @param [String] IP address
    # @param [Integer] Timeout for Geocoder to drop the request
    def get_ip_location(ip, timeout = 5)
      Geocoder::Configuration.cache = Redis.new
      begin
        where = Geocoder.search(ip)
      rescue StandardError => e
        @logger.error "#{e.message}"
      end

      unless where.empty?
        return where.first.country_code
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