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
    #
    # @return [Integer] The HTTP return code or an error code.
    def self.get_response_code(url, proxy_address, proxy_port, timeout=5)
      c = Curl::Easy.new(url)
      c.proxy_url = proxy_address
      c.proxy_port = proxy_port

      begin
        Timeout::timeout(timeout) do
          c.perform
        end
        return c.response_code
      rescue Curl::Err::ConnectionFailedError, Curl::Err::ProxyResolutionError, Timeout::Error => e
        Proxy.delete(proxy_address)
        return 1
      rescue Curl::Err::GotNothingError, Curl::Err::RecvError => e
        Proxy.unavailable(proxy_address)
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
    # @return [Hash]
    def is_response_cached(url)
      redis = Redisdb.new
      data = redis.hgetall(url)
      if ! data['response'].nil?
        return data
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
      check_number = 4 # Number of proxy that we will test the website with
      check_complete = false # Variable that define the status of a check
      responses = [] # Will be use to store response code for each proxy
      run_number = 0 # How many times we tried to get a return code from a proxies group
      entries_to_skip = 0 # Will be use to have uniq group of proxy
      proxies_location = [] # Location of proxies we used

      # Let's check if we are using cache for response code
      feature_flag = YAML.load_file(File.join(File.dirname(__FILE__), '../config/feature_flag.yml'))

      if feature_flag['cache_response_code']
        response_available = is_response_cached(url)

        if response_available
          check_complete = true
          responses << response_available['response']
          @logger.debug "Getting response code #{response_available} from the cache for #{url}"
        end
      end

      while check_complete != true
        begin

          entries_to_skip = 0
          while responses.count != check_number
            proxy = Proxy.get(1, entries_to_skip)[0]

            response_code = Http.get_response_code(url, proxy['server_ip'], proxy['port'].to_i)
            @logger.debug "Checked website #{url} got HTTP response code #{response_code} using proxy #{proxy['server_ip']}:#{proxy['port']}"
            analyse_result = analyse_http_code(response_code)

            if analyse_result
              responses << analyse_result
              proxies_location << proxy['city']
            else
              Proxy.delete(proxy['server_ip'])
            end
            entries_to_skip += 1

          end

          # If after 4 valid return code, all are identical the process is complete
          # If not identical, we empty the array and start over
          if responses.uniq.length == 1
            check_complete = true

            if feature_flag['cache_response_code']
              # Caching the response code for 1 hour
              proxy_data = {}
              proxy_data['response'] = responses.uniq[0]
              proxy_data['cities'] = proxies_location.join(',')
              proxy_data['time'] = Time.now().utc.to_i
              @logger.debug proxy_data

              redis = Redisdb.new()
              redis.hmset(url, proxy_data, 3600)
            end
          else
            @logger.debug("[http]We did not get 4 identical responses code #{responses.inspect}")
            responses = []
            # We will use a different proxy group for each attempt
            # We will skeep N * number_proxy_to_use entries to have a new group every time
            run_number += 1
            entries_to_skip = run_number * number_proxy_to_use
          end
          # If no proxy available
        rescue NotEnoughProxyAvailable => e
          @logger.info "[Http]#{e.message}"
          check_complete = true
          responses << 4444
        end
      end # While check_complete

      if responses.uniq[0].to_i == 200 or responses.uniq[0].to_i == 302 or responses.uniq[0].to_i == 301
        return 'No'
      elsif responses.uniq[0].to_i == 4444
        return 'No servers available, please try your test later'
      else
        return 'Yes'
      end
    end

    # Perform the right action depending of a given HTTP code
    #
    # @param [Integer] http_code HTTP code returned by a proxy
    def analyse_http_code(response_code)
      case response_code
      when 1 then
        # Failure to use the proxy
        return false
      when 400 .. 403 then
        # Proxy asks for authentication
        return false
      when 407 then
        # Proxy asks for authentication
        return false
      when 444 then
        return response_code
      else
        # If we get a valid return code, we add it to the final list
        return response_code
      end
    end

  end
end


