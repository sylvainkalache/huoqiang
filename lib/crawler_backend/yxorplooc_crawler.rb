require File.expand_path('base.rb', File.dirname(__FILE__))

module Huoqiang
  class Yxorplooc < Base
    def initialize()
      super
      @URL = "aHR0cDovL3d3dy5jb29sLXByb3h5Lm5ldC9wcm94aWVzL2h0dHBfcHJveHlf\nbGlzdC9jb3VudHJ5X2NvZGU6Q04vcG9ydDovYW5vbnltb3VzOg==\n"
      @default_duration = 3600
      @enable = false
    end

    def crawl()
    end
  end
end
