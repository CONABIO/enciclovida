#! /bin/bash

cd /usr/local/app_rails/buscador/
redis-server &
sleep 10
rails runner "eval(File.read '/usr/local/app_rails/buscador/tools/levantaServicios/levantaBlurrily.rb')" &
export RAILS_ENV=production
nohup ruby /usr/local/app_rails/buscador/bin/delayed_job -i validaciones --queue=validaciones run &
nohup ruby /usr/local/app_rails/buscador/bin/delayed_job -i descargar_taxa --queue=descargar_taxa run &
nohup ruby /usr/local/app_rails/buscador/bin/delayed_job -i ejemplares_snib--queue=ejemplares_snib run &
nohup ruby /usr/local/app_rails/buscador/bin/delayed_job -i estadisticas --queue=estadisticas run &
nohup ruby /usr/local/app_rails/buscador/bin/delayed_job -i observaciones_naturalista --queue=observaciones_naturalista run &
nohup ruby /usr/local/app_rails/buscador/bin/delayed_job -i redis --queue=redis run &