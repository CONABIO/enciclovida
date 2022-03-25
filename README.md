# ENCICLOVIDA

### _Buscador y administrador de especies de la CONABIO_

Tal vez se necesiten los siguientes paquetes: 

```
libxslt-dev libxml2-dev build-essential openssl libmysqlclient-dev libpq-dev freetds-dev
```

Una vez cargada la base de datos...


Para iniciar el fuzzymatch:
```sh
require 'blurrily/server.rb'
```
```sh
server=Blurrily::Server.new(:host => IP, :directory=> './db/blurrily')
```
```sh
server.start
```
```sh
rails r tools/exporta_blurrily.rb
```

Para usar Redis con soulmate como back-end del autocomplete (Instalación):
```sh
wget http://download.redis.io/redis-stable.tar.gz
```
```sh
tar -xvzf redis-stable.tar.gz
```
```sh
cd redis-stable
```
```sh
make
```
```sh
sudo make install
```

Para levantar redis:
```sh
redis-server # (inicia el servicio)
```

```sh
soulmate-web --foreground --no-launch --redis=redis://localhost:6379/0  # (inicia el servicio con rails)
```
```sh
rails r tools/nombres_comunes_redis.rb -d
```
```sh
rails r tools/nombres_cientificos_redis.rb -d
```

Para poner el nombre común principal:
```sh
rails r tools/nombre_comun_principal.rb -d
```
Para poner la foto principal:
```sh
rails r tools/foto_principal.rb -d
```
Para poder exportar los PDF's con wicked_pdf:
```sh
http://wkhtmltopdf.org/downloads.html
```

Para iniciar el administrador de trabajos pendientes (solo production):
```sh
rake jobs:work
```
