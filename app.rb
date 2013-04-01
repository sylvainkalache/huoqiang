require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib/http.rb')
require File.join(File.dirname(__FILE__), 'lib/image.rb')

module Huoqiang
  class App < Sinatra::Application
    configure do
      set :public_folder, File.dirname(__FILE__) + '/public'
    end

    set :haml, :format => :html5

    get '/' do
      image = Huoqiang::Image.get()
      @image_path = image[0]
      @image_copyright = image[1]
      haml :index
    end

    get '/home' do
      image = Huoqiang::Image.get()
      @image_path = image[0]
      @image_copyright = image[1]
      haml :index
    end

    post '/query' do
      # TODO should be self
      backend = Huoqiang::Http.new()
      result = backend.check_website(params[:url])
      image = Huoqiang::Image.get()

      @url = params[:url]
      @http_return_code = result['response']
      @cities = result['cities'].split(',')
      @image_path = image[0]
      @image_copyright = image[1]

      haml :result
    end

    get '/about' do
      image = Huoqiang::Image.get()
      @image_path = image[0]
      @image_copyright = image[1]
      haml :about
    end

  end
end
