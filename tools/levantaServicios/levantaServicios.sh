#! /bin/bash

cd /usr/local/app_rails/buscador/
redis-server > log/bitacoraScript.log &
sleep 10
soulmate-web --foreground --no-launch --redis=redis://localhost >> log/bitacoraScript.log &
rails runner "eval(File.read '/usr/local/app_rails/buscador/tools/levantaServicios/levantaBlurrily.rb')" &
RAILS_ENV=production /usr/local/app_rails/buscador/bin/delayed_job -n 3 run &
