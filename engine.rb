require 'curb'
require File.expand_path('lib/proxy_sitter.rb', File.dirname(__FILE__))
require 'timeout'

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
  rescue Curl::Err::GotNothingError => e
    return 444
  end
end

# Pass a set of test to check if the website is blocked in China
#
# @url [String] URL of the website to test.
# @return [Integer] Return the HTTP return code or an error code (if website blocked or no proxy available)
def check_website(url)
  response_code = 1
  check_complete = false
  responses = []

  # As long as we don't get 4 identical return code
  while check_complete != true

    # As long as we don't get back a return code from a working proxy
    response_code = 1

    @proxy ||= Proxy.new()
    @proxy.get(4).each do |proxy|
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
    if responses.length == 4
      if responses.uniq.length == 1
        check_complete = true
      else
        proxies = get_proxy(4)
        responses = []
      end
    end

  end # While check_complete
  return response_code
end