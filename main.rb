require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'lib/http.rb')

configure do
  set :public_folder, File.dirname(__FILE__) + '/public'
end

set :haml, :format => :html5

get '/' do
  haml :index
end


post '/query' do
  backend = Huoqiang::Http.new()
  @http_return_code = backend.check_website(params[:url])

  haml :result
end