require 'logger'
require 'geocoder'
require 'redis'
require File.expand_path('../mongodb.rb', File.dirname(__FILE__))

module Huoqiang
  class Base
    def initialize()
      @logger = Logger.new(File.join(File.dirname(__FILE__),'../../logs/collector.log'))
    end

    # Used to delay the execution of crawler processes
    #
    # @param [Integer] duration Sleep for N second betweem each collector run or DefaultDuration if not defined
    def nap(duration = @default_duration)
      sleep duration
    end

    def dance()
      while true
        @proxy_entries = [] # Will contains hashes containing proxy info
        @number_proxy_entries = 0 # Number of entries inserted or updated per crawler

        start_time = Time.now
        crawler_output = crawl()
        total_time = Time.now - start_time

        # We don't apply to same process for updateProxyList as it's not a crawler
        unless @URL == 'updateProxyList'
          @logger.info "Updated #{@number_proxy_entries} entries for #{@URL} in #{total_time}sec"

          @proxy_entries.each do |proxy_entry|
            check_and_update(proxy_entry)
          end
        end

        nap()
      end
    end

    # collect method should return a hash containing log information
    #
    # @return [Hash] return a hash containing value collected
    def crawl()
      raise NotImplementedError, 'You must override this method'
    end

    # Check the proxy data and update to mongoDB if valid
    #
    # @param proxy informations, must contain a 'server_ip' and 'port' keys
    def check_and_update(data)
      if check_data_format(data[:server_ip], data[:port])
        country_code = get_ip_location(data[:server_ip])

        if country_code and country_code.include? 'CN'
          mongo = Mongodb.new
          mongo.update({:server_ip => data[:server_ip]}, data)
        end

      end
    end

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

  end # End class
end # End module