#! /bin/bash

cd /home/enciclovida/buscador/
export RAILS_ENV=production
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
$(which redis-server) &
sleep 10
$(which rails) runner "eval(File.read '$(pwd)/tools/levantaServicios/levantaBlurrily.rb')" &
nohup $(which ruby) $(pwd)/bin/delayed_job -i validaciones --queue=validaciones run &
nohup $(which ruby) $(pwd)/bin/delayed_job -i descargar_taxa --queue=descargar_taxa run &
nohup $(which ruby) $(pwd)/bin/delayed_job -i estadisticas --queue=estadisticas run &
nohup $(which ruby) $(pwd)/bin/delayed_job -i redis --queue=redis run &
nohup $(which ruby) $(pwd)/bin/delayed_job -i peces --queue=peces run &
# Los siguientes delayed job aún no se ocupan pero no se borran hasta que quede listo el módulo de estadísticas
# nohup ruby $(pwd)/bin/delayed_job -i estadisticas_naturalista --queue=estadisticas_naturalista run &
# nohup ruby $(pwd)/bin/delayed_job -i estadisticas_conabio --queue=estadisticas_conabio run &
# nohup ruby $(pwd)/bin/delayed_job -i estadisticas_wikipedia --queue=estadisticas_wikipedia run &
# nohup ruby $(pwd)/bin/delayed_job -i estadisticas_eol --queue=estadisticas_eol run &
# nohup ruby $(pwd)/bin/delayed_job -i estadisticas_tropicos_service --queue=estadisticas_tropicos_service run &
# nohup ruby $(pwd)/bin/delayed_job -i estadisticas_maccaulay --queue=estadisticas_maccaulay run &
# nohup ruby $(pwd)/bin/delayed_job -i estadisticas_SNIB --queue=estadisticas_SNIB run &
# nohup ruby $(pwd)/bin/delayed_job -i estadisticas_mapas_distribucion --queue=estadisticas_mapas_distribucion run &
