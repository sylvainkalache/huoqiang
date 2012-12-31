require 'curb'
require File.join(File.expand_path(File.dirname(__FILE__)),'mongodb.rb')
require File.join(File.expand_path(File.dirname(__FILE__)),'http.rb')

module Huoqiang
  class Proxy

    # Delete a proxy from MongoDB.
    #
    # @param [String] Proxy ip address.
    def self.delete(ip_address)
      mongo = Mongodb.new
      mongo.remove({"server_ip" => ip_address})
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
    # @param [Integer] limit Number of proxy to return.
    # @param [Integer] skip Number of entries to skip
    #
    # @return [Array] Array of hashes.
    def self.get(limit = 1, skip = 0)
      mongo = Mongodb.new
      result = mongo.find({ "latency" => {"$exists" => true}, "unavailable" => false }).sort({"latency" => 1}).limit(limit).skip(skip)

      if result.count < limit
        return false
      else
        proxies = []
        result.each {|entry| proxies << entry}
        return proxies
      end
    end

    # Set the proxy to an unavailable state
    #
    # @param [String] Proxy ip address
    def self.unavailable(ip)
      mongo = Mongodb.new()
      proxy_data = mongo.find_one({"server_ip" => ip})
      proxy_data['unavailable'] = true

      Proxy.update(ip, proxy_data)
    end

    # Test if the proxy is working
    #
    # @param [String] IP address of the proxy.
    # @param [Integer] Port of the proxy.
    # @param [Integer] Time after the HTTP request via curl will timeout.
    #
    # @return [Boolean] Proxy working or not.
    def self.is_working(proxy_address, proxy_port, timeout=5)
      # We are assuming that weibo.com is up
      url = "http://www.weibo.com/"
      c = Curl::Easy.new(url)
      c.proxy_url = proxy_address
      c.proxy_port = proxy_port.to_i

      begin
        Timeout::timeout(timeout) do
          c.perform
        end
        #We are assuming that Weibo page should contain the keyword weibo
        if ! c.body_str.nil? and c.body_str.include? 'weibo'
          return true
        else
          return false
        end

      rescue Curl::Err::ConnectionFailedError, Curl::Err::ProxyResolutionError, Timeout::Error,
        Curl::Err::GotNothingError, Curl::Err::HostResolutionError, Curl::Err::HostResolutionError, StandardError => e
        return false
      ensure
        c.close()
      end

    end # End is_working

    # Test if the really process any request
    # I've noticed that some proxies deny any website
    # which is not Chinese based
    # @param [String] IP address of the proxy.
    # @param [Integer] Port of the proxy.
    # @param [Integer] Time after the HTTP request via curl will timeout.
    #
    # @return [Boolean] Proxy working or not.
    def self.is_trustable(proxy_address, proxy_port, timeout = 5)
      @logger = Huoqiang.logger('crawler')
      # Fair example of a website that should not be censured
      # and should have a pretty good uptime
      url = "http://www.nasa.com/"

      proxy_response_code = Http.get_response_code(url, proxy_address, proxy_port)

      c = Curl::Easy.new(url)
      begin
        Timeout::timeout(timeout) do
          c.perform
        end
      rescue StandardError => e
        # TODO
        # Something went wrong ....
        @logger.error "[Proxy]Could not query #{url} #{e.message}"
      end

      # We are supposed to get the same response code
      # If not, this proxy is probable not trustable
      if c.response_code != proxy_response_code
        return false
      end

      return true
    end # End is_trustable

  end
end