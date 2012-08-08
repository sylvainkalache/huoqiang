require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Xroxy < Base
    def initialize()
      super
      @URL = 'http://www.xroxy.com/proxyrss.xml'
      @default_duration = 18000
    end

    def crawl()
      # Definition or customs tags so that SimpleRSS can pars them
      SimpleRSS.item_tags << :"prx:port"
      SimpleRSS.item_tags << :"prx:ip"
      SimpleRSS.item_tags << :"prx:type"
      SimpleRSS.item_tags << :"prx:country"

      begin
        rss = SimpleRSS.parse open(@URL)
      rescue ::SocketError, ::Timeout::Error, ::Errno::ETIMEDOUT, ::Errno::ENETUNREACH, ::Errno::ECONNRESET, ::Errno::ECONNREFUSED => e
        @logger.error "Xroxy parser: #{e.message}"
      rescue StandardError => e
        @logger.error "Xroxy parser: #{e.message}"
      end

      rss.items.each do |item|
        proxy = {}
        if item.prx_country = 'CN' and ! item.prx_type.include?('Socks')
          proxy[:port] = item.prx_port
          proxy[:server_id] = item.prx_ip
          @proxy_entries << proxy
          @number_proxy_entries += 1
        end
      end
      return @proxy_entries
    end
  end
end