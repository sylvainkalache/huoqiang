require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Eromyxorp < Base
    def initialize()
      super
      @URL = Base64.decode64('aHR0cDovL3d3dy5wcm94eW1vcmUubmV0L3Byb3h5X2FyZWEtQ04uaHRtbA==')
      @default_duration = 7200
      @enable = true
    end

    def crawl()
      begin
        body = open(@URL).read
      rescue OpenURI::HTTPError, EOFError, SocketError => e
        @logger.error "Eromyxorp parser: #{e.message}"
        raise CannotAccessWebsite, "[Eromyxorp]Can't access #{@URL}: #{e.message}"
      end

      doc = Nokogiri::HTML(body)

      doc.css('tr[class="x-tr"]').each do |tr|
        proxy = Hash.new(0)

        # We are assuming that if the string is compose of 2 letters
        # Then the port is equal 80
        if tr.css('td[class="pport"]').text.length == 2
          proxy[:server_ip] = tr.css('td[class="pserver"]').text
          proxy[:port] = 80

          @proxy_entries << proxy
          @number_proxy_entries += 1
        end

      end

    end
  end
end
