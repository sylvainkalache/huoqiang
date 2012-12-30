require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'simple-rss'
require 'logger'

require File.join(File.expand_path(File.dirname(__FILE__)), '../proxy.rb')
require File.join(File.expand_path(File.dirname(__FILE__)),'../logger.rb')

Dir['crawlers/*_crawler.rb'].each do |file|
  require File.join(File.expand_path(File.dirname(__FILE__)), file)
end

module Huoqiang
  class Crawler_sitter

    def initialize
      @logger = Huoqiang.logger('crawler')
    end

    # Start the threads that will crawl proxy providers website/RSS feed
    def start_crawlers
      threads = []

      Dir[File.expand_path('crawlers/*_crawler.rb',File.dirname(__FILE__))].each do |parser_path|
        @logger.debug parser_path
        threads << Thread.new(parser_path) do |thread|
          @number_proxy_entries = 0
          provider_name = File.basename(thread, '_crawler.rb')

          Thread.current['provider_name'] = provider_name

          parser =  Huoqiang.const_get(provider_name.capitalize).new()
          parser.dance()
        end # End threads <<
      end # End Dir.glob

      # Keeping threads up
      threads.each do |thread|
        begin
          @logger.debug "Starting thread for #{thread['name']}"
          thread.join()
        rescue Exception => e
          @logger.error "Problem with #{thread['name']} thread: #{e.message}"
          exit 1
        end

      end # End threads.each
    end # End start_crawlers

  end # End Class
end # End module

crawler_sitter = Huoqiang::Crawler_sitter.new()
crawler_sitter.start_crawlers()
