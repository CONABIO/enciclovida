#! /bin/bash

cd /home/enciclovida/buscador/
#Mata todos los delayed_jobs
ps aux | grep delayed | grep ruby | awk -F ' ' '{print $2}'  | xargs kill;
sleep 12;
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
export RAILS_ENV=production
$(which mongo) --verbose enciclovida_production $(pwd)/tools/levantaServicios/cleanMongoJobs.js >> $(pwd)/log/reinicia_delayed_jobs_mongo.log;

nohup $(which ruby) $(pwd)/bin/delayed_job -i validaciones --queue=validaciones run &
nohup $(which ruby) $(pwd)/bin/delayed_job -i descargar_taxa --queue=descargar_taxa run &
nohup $(which ruby) $(pwd)/bin/delayed_job -i estadisticas --queue=estadisticas run &
nohup $(which ruby) $(pwd)/bin/delayed_job -i redis --queue=redis run &
nohup $(which ruby) $(pwd)/bin/delayed_job -i peces --queue=peces run &
echo "El cron de los delayed_jobs corrio en $(date)" >> $(pwd)/log/cron_delayed_jobs.log;
