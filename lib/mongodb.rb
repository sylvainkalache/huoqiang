require 'mongo'
require 'logger'

module Huoqiang
  class Mongodb
    def initialize()
      @logger = Logger.new(File.join(File.dirname(__FILE__),'../logs/mongo.log'))
      @@collection ||= connection()
    end

    # Establish a connection with a MongoDB server
    #
    # @param [String] MongoDB server IP.
    # @param [String] MongoDB database name.
    # @param [String] Collection that we will query on.
    # @param [Integer] MongoDB server port that we will connect to.
    # @return [Object] MongoDB connection to a @@collection.
    def connection(hostname='127.0.0.1', database='huoqiang', collection='proxy', port=27017)
      begin
        @logger.info "Creating new MongoDB connection"
        connection = Mongo::Connection.new(hostname, port, :slave_ok => false)
      rescue Mongo::ConnectionFailure => e
        @logger.error "#{e.message}"
      end
      connection[database][collection]
    end

    # Process the request against the provided collection
    #
    # @param [Hash] conditions of the MongoDB query
    # @return [Object] BSON hash containing result of the query
    def request(condition={})
      @@collection ||= connection()
      @@collection.find(condition)
    end

    def insert(data)
      @@collection ||= connection()
      @@collection.insert(data)
    end

    def find(request=nil)
      @@collection ||= connection()
      @@collection.find(request)
    end

    def remove(request)
      @@collection ||= connection()
      @@collection.remove(request)
    end

    # @param [Hash] MongoDB will fetch entry with this key/value
    # @param [Hash] MongoDB will update the entries which matched @reference with @data
    def update(reference, data)
      begin
        @@collection ||= connection()
        # Upsert: create record of update if already exists
        @@collection.update(reference, data, {:upsert => true})
      rescue Mongo::OperationFailure => e
        @logger.error "#{e.message}"
      end
    end

  end # Class
end # Module