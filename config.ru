require './app.rb'
 
use Rack::ShowExceptions
 
run Huoqiang::App.new