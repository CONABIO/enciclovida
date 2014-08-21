buscador
========

Buscador y administrador de especies de la CONABIO

Talves se necesiten los sig. paquetes: libxslt-dev libxml2-dev build-essential openssl libmysqlclient-dev libpq-dev



Una vez caragada la base ...


--- Para iniciar el fuzzymatch

mkdir blurrily

require 'blurrily/server.rb'

server=Blurrily::Server.new(:host => '127.0.0.1', :directory=> './db/blurrily')

server.start


--- Para usar Redis con soulmate como back-end del autocomplete (Instalar)

wget http://download.redis.io/redis-stable.tar.gz

tar xvzf redis-stable.tar.gz

cd redis-stable

make

sudo make install


--- Para levantar redis

redis-server (inicia el servicio)

soulmate-web --foreground --no-launch --redis=redis://localhost:6379/0  (inicia el servicio con rails)

rails r tools/nombres_comunes_redis.rb -d

rails r tools/nombres_cientificos_redis.rb -d




--- Para iniciar el administrador de trabajos pendientes (solo production)

./bin/delayed_job run


