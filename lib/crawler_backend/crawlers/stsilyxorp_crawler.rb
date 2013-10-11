require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Stsilyxorp < Base
    def initialize()
      super
      @URL = Base64.decode64('aHR0cDovL3d3dy5wcm94eWxpc3RzLm5ldC9wcm94eWxpc3RzLnhtbA==')
      @default_duration = 7200
      @enable = true
    end

    def crawl()
      # Definition or customs tags so that SimpleRSS can pars them
      SimpleRSS.item_tags << :"prx:port"
      SimpleRSS.item_tags << :"prx:ip"
      SimpleRSS.item_tags << :"prx:type"
      SimpleRSS.item_tags << :"prx:country"

      begin
        rss = SimpleRSS.parse open(@URL)
      rescue ::SocketError, ::Timeout::Error, ::Errno::ETIMEDOUT, ::Errno::ENETUNREACH, ::Errno::ECONNRESET, ::Errno::ECONNREFUSED, EOFError, SocketError => e
        raise CannotAccessWebsite, "[Stsilyxorp]Can't access #{@URL}: #{e.message}"
      end

      rss.items.each do |item|
        proxy = {}
        if item.prx_country = 'China' and ! item.prx_type.include?('Socks')
          proxy[:port] = item.prx_port
          proxy[:server_ip] = item.prx_ip
          @proxy_entries << proxy
          @number_proxy_entries += 1
        end
      end
      return @proxy_entries
    end
  end
end
