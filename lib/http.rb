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
    # @param [String] url URL to test.
    # @param [String] proxy_address IP address of the proxy.
    # @param [Integer] proxy_port Port of the proxy.
    # @param [Integer] timeout Time after the HTTP request via curl will timeout
    #
    # @return [Integer] The HTTP return code or an error code.
    def self.get_response_code(url, proxy_address = nil, proxy_port = nil, timeout=10)
      @logger = Huoqiang.logger('access')
      c, state = Curl_lib.request(url, proxy_address, proxy_port)

      return c.response_code if c

      if state == :to_delete
        Proxy.delete(proxy_address)
        return 1
      elsif state == :firewall_here
        Proxy.unavailable(proxy_address)
        return 444
      elsif state == :unknown
        # TODO
        # Something went wrong ....
        @logger.error("[Http]Could not get response for #{url}: #{e.message}")
        return 000
      end
    end

    # Pass a set of test to check if the website is blocked in China
    #
    # @url [String] url URL of the website to test.
    #
    # @return [Hash] Containing return code and informations about the checks
    def check_website(url)
      check_number = 4 # Number of proxy that we will test the website with
      check_complete = false # Variable that define the status of a check
      responses = [] # Will be use to store response code for each proxy
      run_number = 0 # How many times we tried to get a return code from a proxies group
      entries_to_skip = 0 # Will be use to have uniq group of proxy
      proxies_location = [] # Location of proxies we used
      proxy_data = {}

      # Let's check if we are using cache for response code
      feature_flag = YAML.load_file(File.join(File.dirname(__FILE__), '../config/feature_flag.yml'))

      if feature_flag['cache_response_code']
        response_available = Redisdb.is_hash_cached(url)

        if response_available
          check_complete = true
          responses << response_available['response']
          proxy_data['cities'] = response_available['cities']
          @logger.debug "Getting response code #{response_available} from the cache for #{url}"
        end
      end

      entries_to_skip = 0

      while check_complete != true
        begin
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
            proxy_data['cities'] = []
            proxies_location = []
            # We will use a different proxy group for each attempt
            # We will skeep N * number_proxy_to_use entries to have a new group every time
            run_number += 1
            @logger.debug "entries_to_skip = run_number * check_number"
            @logger.debug "#{entries_to_skip} #{run_number} #{check_number}"
            entries_to_skip = run_number * check_number
          end
          # If no proxy available
        rescue NotEnoughProxyAvailable => e
          @logger.error "[#{self.class}]#{e.message}"
          check_complete = true
          responses << 4444
        rescue StandardError => e
          @logger.error "[#{self.class}]#{e.message}"
          @logger.error e.backtrace
          check_complete = true
          responses << 5555
        end
      end # While check_complete

      if responses.uniq[0].to_i == 200 or responses.uniq[0].to_i == 302 or responses.uniq[0].to_i == 301
        answer = 'No'
      elsif responses.uniq[0].to_i == 4444
        answer = 'No proxies available, please try your test later'
      elsif responses.uniq[0].to_i == 5555
        answer = 'Oops, something went wrong'
      else
        answer = 'Yes'
      end

      return { 'response' => answer, 'cities' => proxy_data['cities']}
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
