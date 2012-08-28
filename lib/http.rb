require 'rubygems'
require 'curb'
require 'timeout'
require File.join(File.dirname(__FILE__), 'proxy_sitter.rb')
require File.join(File.dirname(__FILE__), 'proxy.rb')

module Huoqiang
  class Http

    # TODO
    # Choose a place where to initialize logger
    def initialize
      $logger = Logger.new(File.join(File.dirname(__FILE__),'../logs/collector.log'))
    end

    # Get HTTP response code of the given URL via the given proxy.
    #
    # @url [String] URL to test.
    # @proxy_address [String] IP address of the proxy.
    # @proxy_port [Integer] Port of the proxy.
    # @timeout [Integer] Time after the HTTP request via curl will timeout
    # @return [Integer] The HTTP return code or an error code.
    def get_response_code(url, proxy_address, proxy_port, timeout=5)
$logger.info url
$logger.info proxy_address
$logger.info proxy_port
      c = Curl::Easy.new(url)
#      c.proxy_url = proxy_address
            c.proxy_url = '166.111.134.57'
#      c.proxy_port = proxy_port
      c.proxy_port = proxy_port = 443

      begin
        Timeout::timeout(timeout) do
          c.perform
        end
        return c.response_code
      rescue Curl::Err::ConnectionFailedError, Curl::Err::ProxyResolutionError, Timeout::Error => e
        @proxy ||= Proxy.new()
        @proxy.delete(proxy_address)
        return 1
      rescue Curl::Err::GotNothingError => e
        @proxy ||= Proxy.new()
        @proxy.unavailable(proxy_address)
        return 444
      rescue StandardError => e
        # TODO
        # Something went wrong ....
        $logger.error e.message
      end
    end

    # Pass a set of test to check if the website is blocked in China
    #
    # @url [String] URL of the website to test.
    # @return [Integer] Return the HTTP return code or an error code (if website blocked or no proxy available)
    def check_website(url)
      number_proxy_to_use = 3 # Number of proxy that we will test the website with
      response_code = 1
      check_complete = false
      responses = []

      # As long as we don't get 4 identical return code
      while check_complete != true

        # As long as we don't get back a return code from a working proxy
        response_code = 1

        @proxy ||= Proxy.new()
        @proxy.get(number_proxy_to_use).each do |proxy|
$logger.debug "#{proxy['server_ip']} #{proxy['port']}"
          while response_code == 1
            response_code = get_response_code(url, proxy['server_ip'], proxy['port'])

            # If we get a valide return code, we add it to the final list
            if response_code != 1
              responses << response_code
            end

          end # While response_code
        end

        # If after 4 valid return code, all are identical the process is complete
        # If not identical, we empty the array and start over
        if responses.length == number_proxy_to_use
          if responses.uniq.length == 1
            check_complete = true
          else
            proxies = get_proxy(number_proxy_to_use)
            responses = []
          end
        end

      end # While check_complete
      return response_code
    end
  end
end