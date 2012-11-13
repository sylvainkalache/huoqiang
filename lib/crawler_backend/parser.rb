module Huoqiang
  class Parser

    # Check if there is valid proxy information in the given line
    #
    # @param [String] What ever text
    # @return [Hash, Boolean] Return a Hash with proxy information or false if nothing found
    def is_proxy(line)
      proxy = {}

      # This is probably the most common format
      # "ip:port"
      if line =~ /\d*\.\d*\.\d*\.\d*:(\d+)(\d+)(\d+)(\d+)|\d*\.\d*\.\d*\.\d*:(\d+)(\d+)/
        regex = 1
        proxy[:ip] = line.split(":")[0].chomp()
        proxy[:port] = line.split(':')[1].chomp()

        # We catch anything that looks like an IP address
      elsif line =~ /\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/
        regex = 2
        proxy[:ip] = line[/\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b/].to_s.strip.chomp()

        # We assume that the usual format is
        # "ip port comments"
        # We also asssume that the port contains a least one time the number 8
        # Below is just to catch the port
        if line =~ /\s(\d+)(\d+)(\d+)(\d+)\s|\s(\d+)(\d+)\s/ and line =~ /8{1,}/
          proxy[:port] = line[/\s(\d+)(\d+)(\d+)(\d+)\s|\s(\d+)(\d+)\s/].to_s.gsub(/\t/, ' ').strip.chomp()
        end
      end

      if proxy[:ip] and proxy[:port]
        return proxy
      else
        return false
      end

    end
  end
end