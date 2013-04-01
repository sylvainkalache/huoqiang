require File.expand_path('base.rb', File.dirname(__FILE__))
require File.join(File.expand_path(File.dirname(__FILE__)), '../../proxy.rb')

module Huoqiang
  class Updateproxylist < Base
    def initialize()
      super
      @URL = 'updateProxyList'
      @default_duration = 2700
      @enable = true
    end

    def crawl()
      mongo = Mongodb.new
      proxies = mongo.find()
      proxy_deleted = 0

      @logger.info "[Updateproxylist]Will analyse #{proxies.count}"

      proxies.each do |proxy|
        if Proxy.is_working(proxy[:server_ip], proxy[:port])
          proxy['latency'] = Proxy.latency(proxy[:server_ip], proxy[:port])
          proxy['unavailable'] = false # Proxy is in an available state, aka not being blocked because used to query a censured page

          Proxy.update(proxy[:server_ip], proxy)
        else
          Proxy.delete(proxy[:server_ip])
          proxy_deleted += 1
        end

      end # End proxies.each
      @logger.info "[Updateproxylist]Done updating the proxies, #{proxy_deleted} has been deleted"
    end
  end
end
