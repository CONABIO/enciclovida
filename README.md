buscador
========

Buscador y administrador de especies de la CONABIO

Una vez caragada la base ...

--- Para usar Redis con soulmate como back-end del autocomplete (Instalar)
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
sudo make all

--- Para extraer los metadatos de las imagenes (Instalar)
http://www.imagemagick.org/download/ImageMagick.tar.gz
tar xvzf ImageMagick.tar.gz
cd ImageMagick-6.8.9
./configure
make
make all
sudo ldconfig /usr/local/lib


--- Para iniciar el fuzzymatch
require 'blurrily/server.rb'
server=Blurrily::Server.new(:host => '127.0.0.1', :directory=> './db/blurrily')    //directory es donde quedaran alojados los datos
server.start

rails r tools/nombres_comunes_redis.rb -d
rails r tools/nombres_cientificos_redis.rb -d

redis-server
soulmate-web --foreground --no-launch --redis=redis://localhost:6379/0

--- Para iniciar el administrador de trabajos pendientes (solo production)
./bin/delayed_job run


