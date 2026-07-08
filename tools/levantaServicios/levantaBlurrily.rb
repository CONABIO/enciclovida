require 'blurrily/server.rb'

Blurrily::Server.new(
  host: ENV.fetch('BLURRILY_BIND_HOST', '0.0.0.0'),
  directory: './db/blurrily'
).start