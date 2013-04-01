require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Xroxy < Base
    def initialize()
      super
      @URL = 'http://www.xroxy.com/proxyrss.xml'
      @default_duration = 7200
      @enable = true
    end

    def crawl()
      # Definition or customs tags so that SimpleRSS can pars them
      SimpleRSS.item_tags << :"prx:port"
      SimpleRSS.item_tags << :"prx:ip"
      SimpleRSS.item_tags << :"prx:type"
      SimpleRSS.item_tags << :"prx:country_code"

      begin
        rss = SimpleRSS.parse open(@URL)
      rescue ::SocketError, ::Timeout::Error, ::Errno::ETIMEDOUT, ::Errno::ENETUNREACH, ::Errno::ECONNRESET, ::Errno::ECONNREFUSED, EOFError, SocketError, StandardError => e
        raise CannotAccessWebsite, "[Xroxy]Can't access #{@URL}: #{e.message} #{e.class}"
      end

      rss.items.each do |item|
        proxy = {}
        # Check that these methods are available
        # Might no be the case if the entry for that proxy does not have
        # the country_code and type info
        if defined? item.prx_country_code and defined? item.prx_type
          if item.prx_country_code = 'CN' and ! item.prx_type.include?('Socks')
            proxy[:port] = item.prx_port
            proxy[:server_ip] = item.prx_ip
            @proxy_entries << proxy
            @number_proxy_entries += 1
          end
        end
      end
      return @proxy_entries
    end
  end
end
