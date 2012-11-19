module Huoqiang

    # Provide a logger
    #
    # @param [String] file_name Name of the log file
    def self.logger(file_name)
        @logger ||= Logger.new(File.join(File.dirname(__FILE__),"../log/#{file_name}.log"))
    end
end