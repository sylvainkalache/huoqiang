require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib/http.rb')

configure do
  set :public_folder, File.dirname(__FILE__) + '/public'
end

get '/url' do
  backend = Huoqiang::Http.new
  @data = backend.check_website(params['url']).inspect

  haml :index
end