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
      @image = Huoqiang::Image.get()
      haml :index
    end

    get '/home' do
      @image = Huoqiang::Image.get()
      haml :index
    end

    post '/query' do
      backend = Huoqiang::Http.new()
      @http_return_code = backend.check_website(params[:url])
      @image = Huoqiang::Image.get()
      haml :result
    end

    get '/about' do
       @image = Huoqiang::Image.get()
      haml :about
    end

  end
end
