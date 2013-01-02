require './app.rb'
require 'newrelic_rpm'

use Rack::ShowExceptions
NewRelic::Agent.after_fork(:force_reconnect => true)
 
run Huoqiang::App.new