require 'logger'
require 'geocoder'
require 'redis'

require File.join(File.expand_path(File.dirname(__FILE__)), '../../mongodb.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), '../../proxy.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), '../../data_tool.rb')
require File.join(File.expand_path(File.dirname(__FILE__)),'../../logger.rb')

module Huoqiang
  class Base

    def initialize
      @logger = Huoqiang.logger('crawler')
    end

    # Used to delay the execution of crawler processes
    #
    # @param [Integer] duration Sleep for N second between each collector run or DefaultDuration if not defined
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
          @logger.info "#{@number_proxy_entries} entries to check - Got them from #{@URL} in #{total_time}sec"

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
      data_tool = Data_tool.new()

      if data_tool.check_data_format(data[:server_ip], data[:port])
        country_code = data_tool.get_ip_location(data[:server_ip])

        if country_code and country_code.include? 'CN'
          mongo = Mongodb.new
          mongo.update({:server_ip => data[:server_ip]}, data)
        end

      end
    end

  end # End class
end # End module