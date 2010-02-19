require 'kite'
root = File.dirname(__FILE__)
app = Kite::Application.new(root)
run app.server

