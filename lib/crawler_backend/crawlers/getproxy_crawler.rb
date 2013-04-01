require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Getproxy < Base
    def initialize()
      super
      @URL='http://www.getproxy.jp/en/china'
      @default_duration = 7200
      @enable = true
    end

    def crawl()
      page_number = 1 # The page number that we are parsing
      begin
        body = open("#{@URL}/1").read
      rescue OpenURI::HTTPError, EOFError, SocketError => e
        raise CannotAccessWebsite, "[Getproxy]Can't access #{@URL}: #{e.message}"
      end
      doc = Nokogiri::HTML(body)

      # Let's count the number of page we have to crawl
      div = doc.css('div[class="pagination"]')
      div.css('a').each do |a|
        if a['title'] =~ /page [0-9]/
          page_number += 1
        end
      end

      # Let's parss all the pages
      # page_number until 2 since we already get the body of the first page
      while (page_number >= 1)

        doc.css('tr[class="white"]').each do |tr|
          proxy = {}
          proxy[:server_ip] = tr.css('td')[0].text.split(':')[0]
          proxy[:port] = tr.css('td')[0].text.split(':')[1].to_i

          @proxy_entries << proxy
          @number_proxy_entries += 1
        end

        doc.css('tr[class="gray"]').each do |tr|
          proxy = {}
          proxy[:server_ip] = tr.css('td')[0].text.split(':')[0]
          proxy[:port] = tr.css('td')[0].text.split(':')[1].to_i

          @proxy_entries << proxy
          @number_proxy_entries += 1
        end

        page_number -= 1
        body = open("#{@URL}/#{page_number}").read
        doc = Nokogiri::HTML(body)
      end # End while
      return @proxy_entries
    end # End crawl
  end # End Getproxy
end # End Module