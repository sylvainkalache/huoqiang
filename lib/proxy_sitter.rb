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
          provider_name = File.basename(thread, '_parser.rb')

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

    # Update the proxy present in MongoDB
    def update_proxy_list
      mongo = Mongodb.new
      proxies = mongo.find()
      proxy_tool = Proxy.new()

      proxies.each do |proxy|
        start_time = Time.now
        response = proxy_tool.is_working(proxy[:server_ip], proxy[:port])
        total_time = Time.now - start_time

        # If the proxy does not respond or has a latency > 5 seconds, we delete it.
        if ! response or total_time > 5
          proxy_tool.delete(proxy['server_ip'])
          @logger.info "Deleted proxy #{proxy['server_ip']} with latency #{proxy['latency']} "

          # If the proxy answered and has a latency < 5 seconds, update its entry.
        elsif total_time < 5
          proxy['latency'] = total_time
          proxy_tool.update(proxy['server_ip'], proxy)
          @logger.info "Updated proxy #{proxy['server_ip']} with latency #{proxy['latency']} "

        end

      end # End proxies.each
      @logger.info "Done updating the proxies"
    end # End update_proxy_list

  end # End Class
end # End module
