require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class TextFile < Base
    # Take in input any text file
    def crawl(file)
      File.foreach(file) do |line|
        proxy = {}

        # This is probably the most common format
        # "ip:port"
        if line =~ /\d*\.\d*\.\d*\.\d*:(\d+)(\d+)(\d+)(\d+)|\d*\.\d*\.\d*\.\d*:(\d+)(\d+)/
          regex = 1
          proxy[:ip] = line.split(":")[0]
          proxy[:port] = line.split(':')[1]

          # We catch anything that looks like an IP address
        elsif line =~ /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
          regex = 2
          proxy[:ip] = line[/\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/].to_s.strip

          # We assume that the usual format is
          # "ip port comments"
          # We also asssume that the port contains a least one time the number 8
          # Below is just to catch the port
          if line =~ /\s(\d+)(\d+)(\d+)(\d+)\s|\s(\d+)(\d+)\s/ and line =~ /8{1,}/
            proxy[:port] = line[/\s(\d+)(\d+)(\d+)(\d+)\s|\s(\d+)(\d+)\s/].to_s.gsub(/\t/, ' ').strip
          end

          unless proxy[:port].nil?
            @logger.info "Catched #{proxy} via regex #{regex}"
            puts catched
          end
        end
      end

    end
  end
end