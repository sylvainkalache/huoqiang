module Huoqiang
  class Curl_lib

    def self.request(url, proxy_address = nil, proxy_port = nil, timeout = 15)
      @logger = Huoqiang.logger('access')

      c = Curl::Easy.new(url)

      if proxy_address && proxy_port
        c.proxy_url = proxy_address
        c.proxy_port = proxy_port.to_i
      end

      begin
        Timeout::timeout(timeout) do
          c.perform
        end

        return c
      rescue Curl::Err::ConnectionFailedError, Curl::Err::ProxyResolutionError, Timeout::Error => e
        return false, :to_delete
      rescue Curl::Err::GotNothingError, Curl::Err::RecvError => e
        return false, :firewall_here
      rescue StandardError => e
        return false
      end
    end

  end
end
