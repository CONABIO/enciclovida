db.delayed_backend_mongoid_jobs.updateMany({queue: 'estadisticas', attempts: 1}, {$unset: {failed_at:1}} );
db.delayed_backend_mongoid_jobs.updateMany({queue: 'descargar_taxa', attempts: 1}, {$unset: {failed_at:1}} );

db.delayed_backend_mongoid_jobs.updateMany({queue: 'estadisticas', attempts: 1}, {$unset: {last_error:1}} );
db.delayed_backend_mongoid_jobs.updateMany({queue: 'descargar_taxa', attempts: 1}, {$unset: {last_error:1}} );

db.delayed_backend_mongoid_jobs.updateMany({queue: 'estadisticas', attempts: 1}, {$unset: {locked_by:1}} );
db.delayed_backend_mongoid_jobs.updateMany({queue: 'descargar_taxa', attempts: 1}, {$unset: {locked_by:1}} );

db.delayed_backend_mongoid_jobs.updateMany({queue: 'estadisticas', attempts: 1}, {$unset: {locked_at:1}} );
db.delayed_backend_mongoid_jobs.updateMany({queue: 'descargar_taxa', attempts: 1}, {$unset: {locked_at:1}} );

db.delayed_backend_mongoid_jobs.updateMany({queue: 'estadisticas', attempts: 1}, {$set: {attempts:0}} );
db.delayed_backend_mongoid_jobs.updateMany({queue: 'descargar_taxa', attempts: 1}, {$set: {attempts:0}} );

db.getCollection('delayed_backend_mongoid_jobs').deleteMany({queue: 'redis', attempts: 1})
