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
        if @enable
          @proxy_entries = [] # Will contains hashes containing proxy info
          @number_proxy_entries = 0 # Number of entries inserted or updated per crawler
          source = self.class.name.split('::').last

          start_time = Time.now
          begin
            crawler_output = crawl()

            total_time = Time.now - start_time

            # We don't apply to same process for updateProxyList as it's not a crawler
            unless @URL == 'updateProxyList'
              @logger.info "#{@number_proxy_entries} entries to check from #{@URL} in #{total_time}sec"

              @proxy_entries.each do |proxy_entry|
                check_and_update(proxy_entry, source)
              end
            end
          rescue CannotAccessWebsite => e
            @logger.error e.message
          end
        end
        @logger.info("Finished to process #{@URL}, will nap for #{@default_duration}")
        nap()
      end
    end

    # collect method should return a hash containing log information
    #
    # @return [Hash] return a hash containing value collected
    def crawl()
      raise NotImplementedError, 'You must override this method'
    end

    # Check the proxy data and update the MongoDB entry if valid
    #
    # @param [Hash] data Proxy informations, must contain a :server_ip and :port keys
    # @param [String] source Where did we get this proxy from
    def check_and_update(data, source = {})
      mongo = Mongodb.new()

      working, reason = Proxy.is_working(data[:server_ip], data[:port].to_i)
      if working
        data.update({:city => Data_tool.get_ip_city(data[:server_ip])})
        data[:source] = source if source
        data[:unavailable] = false
        data[:latency] = Proxy.latency(data[:server_ip], data[:port].to_i)

        mongo.update({:server_ip => data[:server_ip]}, data)
      else
        @logger.debug("#{data} deleted because not working - #{source} - #{reason} failed")
        Proxy.delete(data[:server_ip])
      end
    end

    class CannotAccessWebsite < Exception
    end

  end # End class
end # End module
