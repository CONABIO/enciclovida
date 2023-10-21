#! /bin/bash

cd /home/enciclovida/buscador/
#Mata todos los delayed_jobs
ps aux | grep delayed | awk -F ' ' '{print $2}'  | xargs kill;
mongo --verbose enciclovida_production ./tools/levantaServicios/cleanMongoJobs.js;
export RAILS_ENV=production
nohup ruby $(pwd)/bin/delayed_job -i validaciones --queue=validaciones run > log/delayed_validaciones.log &
nohup ruby $(pwd)/bin/delayed_job -i descargar_taxa --queue=descargar_taxa run > log/delayed_descargas.log &
nohup ruby $(pwd)/bin/delayed_job -i estadisticas --queue=estadisticas run > log/delayed_estadisticas.log &
nohup ruby $(pwd)/bin/delayed_job -i redis --queue=redis run > log/delayed_redis.log &
nohup ruby $(pwd)/bin/delayed_job -i peces --queue=peces run > log/delayed_peces.log &
