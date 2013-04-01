require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Proxybesplatno < Base
    def initialize()
      super
      @URL='http://proxy-besplatno.com/from/China/&page_num='
      @default_duration = 7200
      @enable = true
    end

    def crawl()
      proxy = {}
      @proxy_entries = []
      @number_proxy_entries = 0
      begin
        body = open("#{@URL}1").read
      rescue OpenURI::HTTPError, Timeout::Error, EOFError, SocketError => e
        raise CannotAccessWebsite, "[Proxybesplatno]Can't access #{@URL}: #{e.message}"
      end
      doc = Nokogiri::HTML(body)

      page_number = doc.css('a[class="page_num"]').last.text.to_i

      # Let's parss all the pages
      while (page_number >= 1)
        doc.css('tr[class="tr_index"]').each do |tr|
          proxy = {}
          proxy[:server_ip] = tr.css('td')[0].text.gsub(' ','').chomp


          # Black magic starts here
          # To bypass the protection where the port are actually pictures
          # Each picture size in bytes corresponds to a specific port
          begin
            Net::HTTP.start('proxy-besplatno.com', 80) do |http|
              response = http.request_head("/#{tr.css('td')[1].css('img')[0]['src']}")
              @file_size = response['content-length']
            end
          rescue StandardError => e
            @logger.error "Proxybesplatno: #{e.message}"
            retry
          end

          case @file_size.to_i
          when 1287
            proxy[:port] = 80
          when 1288
            proxy[:port] = 81
          when 1303
            proxy[:port] = 82
          when 1302
            proxy[:port] = 84
          when 1294
            proxy[:port] = 85
          when 1293
            proxy[:port] = 86
          when 1291
            proxy[:port] = 88
          when 1523
            proxy[:port] = 443
          when 1489 .. 1500
            proxy[:port] = 808
          when 1660
            proxy[:port] = 1989
          when 1674
            proxy[:port] = 3128
          when 1753
            proxy[:port] = 3129
          when 1729
            proxy[:port] = 6666
          when 1760
            proxy[:port] = 6668
          when 1715
            proxy[:port] = 6675
          when 1691
            proxy[:port] = 8000
          when 1701
            proxy[:port] = 8001
          when 1694
            proxy[:port] = 8080
          when 1694
            proxy[:port] = 8081
          when 1776
            proxy[:port] = 8082
          when 1782
            proxy[:port] = 8084
          when 1731 .. 1737
            proxy[:port] = 8085
          when 1734
            proxy[:port] = 8083
          when 1777
            proxy[:port] = 8089
          when 1749
            proxy[:port] = 8090
          when 1748
            proxy[:port] = 8086
          when 1664
            proxy[:port] = 8118
          when 1675, 1718
            proxy[:port] = 8123
          when 1685
            proxy[:port] = 8181
          when 1759
            proxy[:port] = 8888
          when 1773
            proxy[:port] = 8909
          when 1752
            proxy[:port] = 9000
          when 1832
            proxy[:port] = 9415
          when 1783
            proxy[:port] = 9999
          else
            @logger.error "Proxybesplatno: #{proxy[:server_ip]} has a unknown port not listed page #{page_number}"
          end

          # We don't want to get banned for abusive crawling :-)
          sleep 2

          @proxy_entries << proxy
          @number_proxy_entries += 1
        end
        page_number -= 1
        body = open("#{@URL}#{page_number}").read
        doc = Nokogiri::HTML(body)
      end # End while
      return @proxy_entries
    end
  end
end