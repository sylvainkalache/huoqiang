require 'open-uri'
require 'nokogiri'
require 'simple-rss'
require 'logger'
require "./proxy.rb"
require "./parser.rb"

require File.expand_path('./../engine.rb', File.dirname(__FILE__))
Dir[File.expand_path('crawler/*',File.dirname(__FILE__))].each do |file|
  require file
end

module Huoqiang
  class Proxy_sitter

    def initialize()
      @logger = Logger.new(File.join(File.dirname(__FILE__),'../logs/collector.log'))
    end

    # Start the threads that will crawl proxy providers website/RSS feed
    def start_crawlers
      threads = []

      Dir.glob(File.join(File.dirname(__FILE__), 'crawler/*_crawler.rb')) do |parser_path|
        threads << Thread.new(parser_path) do |thread|
          @number_proxy_entries = 0
          provider_name = File.basename(thread, '_crawler.rb')

          Thread.current['provider_name'] = provider_name

          parser =  Huoqiang.const_get(provider_name.capitalize).new()
          parser.dance()

          # Keeping threads up
          threads.each do |thread|
            begin
              thread.join()
            rescue StandardError => e
              @logger.error "Problem with #{thread['name']} thread: #{e.message}"
              exit 1
            end

          end # End threads.each
        end # End threads <<
      end # End Dir.glob
    end # End start_crawlers

  end # End Class
end # End module
