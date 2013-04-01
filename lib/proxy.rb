require 'curb'
require File.join(File.expand_path(File.dirname(__FILE__)),'mongodb.rb')
require File.join(File.expand_path(File.dirname(__FILE__)),'http.rb')
require File.join(File.expand_path(File.dirname(__FILE__)),'curl_lib.rb')
require File.join(File.expand_path(File.dirname(__FILE__)),'data_tool.rb')

module Huoqiang
  class Proxy < Data_tool

    # Delete a proxy fron the DB
    #
    # @param [String] Proxy ip address.
    # @param [String] Reason of deletion
    def self.delete(ip_address, deletion_reason = nil)
      @logger = Huoqiang.logger('access')
      mongo = Mongodb.new
      mongo.remove({"server_ip" => ip_address})
      unless deletion_reason.nil?
        @logger.info(deletion_reason)
      end
    end

    # Update a proxy entry
    #
    # @param [String] IP address of the proxy
    # @param [Hash] Containing new proxy information
    def self.update(ip_address, proxy_data)
      mongo = Mongodb.new
      proxy_data.delete('_id') # We can't update the "_id" field.
      mongo.update({"server_ip" => ip_address}, proxy_data)
    end

    # Return the best proxies (based on lantency).
    #
    # @param [Integer] number Number of proxy to return.
    # @param [Integer] skip Number of entries to skip
    #
    # @return [Array] Array of hashes.
    def self.get(number, skip = 0)
      mongo = Mongodb.new
      result = mongo.find({ "latency" => {"$exists" => true}, "unavailable" => false }).sort({"latency" => 1}).skip(skip).limit(number)

      if result.count < number
        raise NotEnoughProxyAvailable, "Not enough proxy available"
      else

        proxies = []
        result.each {|entry|
          proxies << entry
        }

        return proxies
      end
    end

    # Set the proxy to an unavailable state
    #
    # @param [String] Proxy ip address
    def self.unavailable(ip)
      mongo = Mongodb.new()
      proxy_data = mongo.find_one({"server_ip" => ip})
      if proxy_data
        proxy_data['unavailable'] = true
        Proxy.update(ip, proxy_data)
      else
        return false
      end
    end

    # Test if the proxy is serving Weibo properly
    #
    # @param [String] IP address of the proxy.
    # @param [Integer] Port of the proxy.
    #
    # @return [Boolean] Proxy working or not.
    def self.is_serving_weibo(proxy_address, proxy_port)
      # We are assuming that weibo.com is up
      result, state = Curl_lib.request("http://www.weibo.com/", proxy_address, proxy_port)
      if result and ! result.body_str.nil? and result.body_str.include? '0398-130'
        return true
      else
        return false
      end
    end

    # Pass a series of test to decide whether we keep the proxy or not
    #
    # @param [String] IP address of the proxy.
    # @param [Integer] Port of the proxy.
    #
    # @return [Boolean] Did it passed successfully all the test
    # @return [String] If failed, what check it did not passed
    def self.is_working(proxy_address, proxy_port)
      @logger = Huoqiang.logger('crawler')

      ['check_data_format',
        'is_in_china',
        'is_serving_weibo',
        'is_trustable'
      ].each do |method|
        unless Proxy.send(method.to_sym, proxy_address, proxy_port)
          return false, method
          break
        end
      end

      return true, ''
    end


    # Check if a proxy is located in China
    #
    # @param [String] IP address of the proxy
    # @param [Null] args Used in is_working method to have
    # dynamic method execution
    #
    # @return [Boolean]
    def self.is_in_china(proxy_address, *args)
      geo_ip = Data_tool.get_ip_location(proxy_address)

      if geo_ip and geo_ip[:country_code] == 'CN'
        return true
      else
        return false
      end
    end

    # Test if the really process any request
    # I've noticed that some proxies deny any website
    # which is not Chinese based
    #
    # @param [String] IP address of the proxy.
    # @param [Integer] Port of the proxy.
    # @param [Integer] Time after the HTTP request via curl will timeout.
    #
    # @return [Boolean] Proxy working or not.
    def self.is_trustable(proxy_address, proxy_port, timeout = 5)
      @logger = Huoqiang.logger('crawler')
      proxy_response_code = {}
      real_response_code = {}

      # Fair example of a website that should not be censured
      # and should have a pretty good uptime
      url = ["http://www.amazon.com/", "http://www.intrinsec.com/"]

      # Get responses code going through the proxy
      url.each do |url|
        proxy_response_code[url] = Http.get_response_code(url, proxy_address, proxy_port)
        real_response_code[url] = Http.get_response_code(url)
      end
      # We are supposed to get the same response code
      # If not, this proxy is probable not trustable
      if  real_response_code != proxy_response_code
        return false
      else
        return true
      end
    end # End is_trustable

    def self.latency(proxy_address, proxy_port)
      start_time = Time.now()
      response = Curl_lib.request("http://www.weibo.com/", proxy_address, proxy_port)
      Time.now - start_time
    end

  end
end

class NotEnoughProxyAvailable < Exception
end
