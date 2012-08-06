require 'rubygems'
require 'sinatra'
require '/Users/sylvainkalache/Desktop/engine.rb'

get '/url' do
#  puts params
  "#{params}"
  
  "#{check_website(params['url'])}"
end