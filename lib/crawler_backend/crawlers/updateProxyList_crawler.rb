require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Updateproxylist < Base
    def initialize()
      super
      @URL = 'updateProxyList'
      @default_duration = 3600
    end

    def crawl()
      mongo = Mongodb.new
      proxies = mongo.find()
      proxy_tool = Proxy.new()
      timeout = 5
      proxy_deleted = 0

      proxies.each do |proxy|
        start_time = Time.now()
        response = proxy_tool.is_working(proxy['server_ip'], proxy['port'], timeout)
        total_time = Time.now - start_time

        # If the proxy does not respond or has a latency > 5 seconds, we delete it.
        if response
          proxy['latency'] = total_time
          proxy['unavailable'] = false # Proxy is in an available state, aka not being blocked because used to query a censured page
          proxy_tool.update(proxy['server_ip'], proxy)
        else
          proxy_tool.delete(proxy['server_ip'])
          proxy_deleted += 1
        end

      end # End proxies.each
      @logger.info "Done updating the proxies, #{proxy_deleted} has been deleted"
    end
  end
end