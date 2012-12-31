require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Proxy4ever < Base
    def initialize()
      super
      @URL = 'http://www.proxy4ever.com/search/china/feed/rss2/'
      @default_duration = 18000
      @enable = true
    end

    def crawl()
      begin
        rss = SimpleRSS.parse open(@URL)
      rescue ::SocketError, ::Timeout::Error, ::Errno::ETIMEDOUT, ::Errno::ENETUNREACH, ::Errno::ECONNRESET, ::Errno::ECONNREFUSED, EOFError => e
        puts "Proxy4ever parser: #{e.message}"
      rescue StandardError => e
        puts "Proxy4ever parser: #{e.message}"
      end

      unless rss.nil?
        rss.items.each do |item|
          doc = Nokogiri::HTML(item.content_encoded)
          doc.css('p').each do |p|
            proxy = {}

            server_ip = p.css('b')[0].text.split(':')[0]
            port = p.css('b')[0].text.split(':')[1].split(' ')[0]
            country = p.css('b')[1].text

            if country == 'China'
              proxy[:server_ip] = server_ip
              proxy[:port] = port

              @proxy_entries << proxy
              @number_proxy_entries += 1
            end
          end

        end # End rss.items
      end # unless
      return @number_proxy_entries
    end # End crawl

  end # End class
end # End module
