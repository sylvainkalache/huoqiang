require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Ipcn < Base
    def initialize()
      super
      @URL = 'http://proxy.ipcn.org/proxylist.html'
      @default_duration = 18000
    end

    def crawl()
      begin
        body = open(@URL).read
      rescue OpenURI::HTTPError => e
        @logger.error "Ipcn parser: #{e.message}"
      end
 @proxy_entries= []
 @number_proxy_entries = 0
      doc = Nokogiri::HTML(body)

      pre = doc.css('pre')
      pre.text.scan(/.*\n/).each do |line|
        proxy = {}
        parser = Parser.new()
        potential_proxy = parser.is_proxy(line)

        if potential_proxy
          @proxy_entries << potential_proxy
          @number_proxy_entries += 1
        end # End if
      end # End doc

    end
  end
end