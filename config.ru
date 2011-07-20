load './boot.rb'

use Rack::CommonLogger
use Rack::ShowExceptions
use Rack::Session::Cookie
use Faye::RackAdapter, :mount => '/stars', :timeout => 45, :extensions => [Async.new]
run Application
