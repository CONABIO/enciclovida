buscador
========

Buscador y administrador de especies de la CONABIO

--- Para iniciar el fuzzymatch
require 'blurrily/server.rb'
server=Blurrily::Server.new(:host => '127.0.0.1', :directory=> './db/blurrily')    //directory es donde quedaran alojados los datos
server.start

--para usar Redis con soulmate como back-end del autocomplete
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make

rails r tools/nombres_comunes_redis.rb -d
rails r tools/nombres_cientificos_redis.rb -d

redis-server
soulmate-web --foreground --no-launch --redis=redis://localhost:6379/0


