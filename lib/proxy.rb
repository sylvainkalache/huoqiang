require 'curb'

module Huoqiang
  class Proxy
    def initialize()
      @logger = Logger.new(File.join(File.dirname(__FILE__),'../logs/collector.log'))
    end

    # Delete a proxy from MongoDB.
    #
    # @param [String] Proxy ip address.
    def delete(ip_address)
      mongo = Mongodb.new
      mongo.remove({"server_ip" => ip_address})
    end

    # Update a proxy entry
    #
    # @param [String] IP address of the proxy
    # @param [Hash] Containing new proxy information
    def update(ip_address, proxy_data)
      mongo = Mongodb.new
      proxy_data.delete('_id') # We can't update the "_id" field.
      mongo.update({"server_ip" => ip_address}, proxy_data)
    end

    # Return the best proxy (based on lantency).
    #
    # @param [Integer] Number of proxy to return.
    # @return [Array] Array of hashes.
    def get(number = 1)
      mongo = Mongodb.new
      result = mongo.find({ "latency" => {"$exists" => true}}).sort({"latency" => 1}).limit(number)

      entries = []
      result.each {|entry| ip << entry}
      return ip
    end


    # Test if the proxy is working
    #
    # @param [String] IP address of the proxy.
    # @param [Integer] Port of the proxy.
    # @param [Integer] Time after the HTTP request via curl will timeout.
    # @return [Boolean] Proxy working or not.
    def is_working(proxy_address, proxy_port, timeout=5)
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
#        @logger.error "Tried to reach #{url} with #{proxy_address}: #{e.message}"
        return false
      ensure
        c.close()
      end

    end # End is_working

  end
end