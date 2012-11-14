require 'rubygems'
require 'curb'
require 'timeout'
require 'yaml'
require File.join(File.dirname(__FILE__), 'proxy.rb')
require File.join(File.dirname(__FILE__), 'redisdb.rb')
require File.join(File.dirname(__FILE__),'logger.rb')

module Huoqiang
  class Http

    def initialize
      @logger = Huoqiang.logger('access')
    end

    # Get HTTP response code of the given URL via the given proxy.
    #
    # @url [String] URL to test.
    # @proxy_address [String] IP address of the proxy.
    # @proxy_port [Integer] Port of the proxy.
    # @timeout [Integer] Time after the HTTP request via curl will timeout
    # @return [Integer] The HTTP return code or an error code.
    def get_response_code(url, proxy_address, proxy_port, timeout=5)
      c = Curl::Easy.new(url)
      c.proxy_url = proxy_address
      c.proxy_port = proxy_port

      begin
        Timeout::timeout(timeout) do
          c.perform
        end
        return c.response_code
      rescue Curl::Err::ConnectionFailedError, Curl::Err::ProxyResolutionError, Timeout::Error => e
        @proxy ||= Proxy.new()
        @proxy.delete(proxy_address)
        return 1
      rescue Curl::Err::GotNothingError, Curl::Err::RecvError => e
        @proxy ||= Proxy.new()
        @proxy.unavailable(proxy_address)
        return 444
      rescue StandardError => e
        # TODO
        # Something went wrong ....
        @logger.error e.message
      end
    end

    # Check if we have the website's response code in the cache
    #
    # @param [String] url
    #
    # @return [String]
    def is_response_code_cached(url)
      redis = Redisdb.new
      if redis.get(url)
        return redis.get(url)
      else
        return false
      end
    end

    # Pass a set of test to check if the website is blocked in China
    #
    # @url [String] url URL of the website to test.
    #
    # @return [Integer] Return the HTTP return code or an error code (if website blocked or no proxy available)
    def check_website(url)
      number_proxy_to_use = 3 # Number of proxy that we will test the website with
      check_complete = false # Variable that define the status of a check
      responses = [] # Will be use to store response code for each proxy
      run_number = 0 # How many times we tried to get a return code from a proxies group
      entries_to_skip = 0 # Will be use to have uniq group of proxy

      # Let's check if we are using cache for response code
      feature_flag = YAML.load_file(File.join(File.dirname(__FILE__), '../config/feature_flag.yml'))

      if feature_flag['cache_response_code']
        response_code_available = is_response_code_cached(url)

        if response_code_available
          check_complete = true
          responses << response_code_available
          @logger.debug "Getting response code #{response_code_available} from the cache for #{url}"
        end
      end

      @proxy ||= Proxy.new() unless response_code_available

      # As long as we don't get 4 identical return code
      while check_complete != true
        proxies = @proxy.get(number_proxy_to_use, entries_to_skip)

        # Check that we have proxies available
        if proxies
          proxies.each do |proxy|
            response_code = get_response_code(url, proxy['server_ip'], proxy['port'].to_i)
            @logger.debug "Checked website #{url} got HTTP response code #{response_code} using proxy #{proxy['server_ip']}:#{proxy['port']}"

            case response_code
            when 1 then
              @proxy.delete(proxy['server_ip']) # Failure to use
            when 400 then
              @proxy.delete(proxy['server_ip']) # Ask for authentication
            when 444 then
              @proxy.unavailable(proxy['server_ip']) # Just blocked that proxy due to censured website
              responses << response_code
            else
              # If we get a valid return code, we add it to the final list
              responses << response_code
            end
            #TODO if run_number > 10 something went wrong...
          end

          # If after 4 valid return code, all are identical the process is complete
          # If not identical, we empty the array and start over
          if responses.length == number_proxy_to_use && responses.uniq.length == 1
            check_complete = true

            if feature_flag['cache_response_code']
              # Caching the response code for 1 hour
              redis = Redisdb.new()
              redis.set(url, responses.uniq[0], 3600)
            end
          else
            responses = []
            # We will use a different proxy group for each attempt
            # We will skeep N * number_proxy_to_use entries to have a new group every time
            run_number += 1
            entries_to_skip = run_number * number_proxy_to_use
          end
          # If no proxy available
        else
          check_complete = true
          responses << 4444
          @logger.info "No proxy currently available"
        end
      end # While check_complete

      return responses.uniq[0]
    end
  end
end