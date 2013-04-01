require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Nntime < Base
    def initialize()
      super
      @URL='http://nntime.com/'
      @default_duration = 7200
      @enable = true
    end

    def crawl()
      page_number = 1 # The page number that we are parsing

      # TODO
      # I don't think we need the open part
      # cf http://nokogiri.org/tutorials/parsing_an_html_xml_document.html
      begin
        body = open("#{@URL}proxy-country-01.htm").read
      rescue OpenURI::HTTPError, EOFError, SocketError => e
        raise CannotAccessWebsite, "[Nntime]Can't access #{@URL}: #{e.message}"
      end
      doc = Nokogiri::HTML(body)

      # Let's count the number of page we have to crawl
      page_number = 0
      div = doc.css('div[id="navigation"]')
      div.css('a').each do |a|
        page_number += 1
      end

      # Let's parss all the pages
      # page_number until 2 since we already get the body of the first page
      while (page_number >= 2)

        doc.css('tr[class="even"]').each do |tr|
          proxy = {}
          server_ip_to_pars = tr.css('td')[1].text.split(':')[0].to_s
          proxy[:server_ip] = server_ip_to_pars[/\d*\.\d*\.\d*\.\d*/]

          # Some black magic to bypass site protection
          # We get the number of + in this javascript function
          # Which correspond to the number of last digit to take from
          # an 'encrypted/long' number
          port_digit_nb = tr.css('td')[1].text.split(':')[1].count('+')
          port_to_pars = tr.css('td')[0].css('input')[0]['value'].gsub('.','')
          proxy[:port] = port_to_pars.split(//).last(port_digit_nb).join()

          @proxy_entries << proxy
          @number_proxy_entries += 1
        end

        doc.css('tr[class="even"]').each do |tr|
          proxy = {}
          server_ip_to_pars = tr.css('td')[1].text.split(':')[0].to_s
          proxy[:server_ip] = server_ip_to_pars[/\d*\.\d*\.\d*\.\d*/]

          # Some black magic to bypass site protection
          # We get the number of + in this javascript function
          # Which correspond to the number of last digit to take from
          # an 'encrypted/long' number
          port_digit_nb = tr.css('td')[1].text.split(':')[1].count('+')
          port_to_pars = tr.css('td')[0].css('input')[0]['value'].gsub('.','')
          proxy[:port] = port_to_pars.split(//).last(5).join()

          @proxy_entries << proxy
          @number_proxy_entries += 1
        end

        page_number -= 1
        body = open("#{@URL}/proxy-country-#{sprintf '%02d', page_number}.htm").read
        doc = Nokogiri::HTML(body)
      end # End while
      return @proxy_entries
    end # End crawl
  end # End Getproxy
end # End Module