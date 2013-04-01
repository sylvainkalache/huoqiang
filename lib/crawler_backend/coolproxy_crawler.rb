require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Coolproxy < Base
    def initialize()
      super
      @URL = 'http://www.cool-proxy.net/proxies/http_proxy_list/country_code:CN/port:/anonymous:'
      @default_duration = 3600
      @enable = false
    end

    def crawl()
    end
  end
end