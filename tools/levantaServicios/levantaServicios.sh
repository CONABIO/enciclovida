#! /bin/bash

cd /usr/local/app_rails/buscador/
redis-server &
sleep 10
rails runner "eval(File.read '/usr/local/app_rails/buscador/tools/levantaServicios/levantaBlurrily.rb')" &
export RAILS_ENV=production
/usr/local/app_rails/buscador/bin/delayed_job -n 2 run &
