require 'kite/rack'

config = 

Rack::Builder.new do
  run Kite::Rack, config
end

