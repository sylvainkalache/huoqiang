require File.join(File.dirname(__FILE__), '../parser.rb')
require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Ncpi < Base
    def initialize()
      super
      @URL = Base64.decode64('aHR0cDovL3Byb3h5LmlwY24ub3JnL3Byb3h5bGlzdC5odG1s')
      @default_duration = 7200
      @enable = true
    end

    def crawl()
      begin
        body = open(@URL).read
      rescue OpenURI::HTTPError, EOFError, SocketError => e
        raise CannotAccessWebsite, "[Ncpi]Can't access #{@URL}: #{e.message}"
      end

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
