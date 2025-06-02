# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# https://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: https://github.com/javan/whenever
set :environment, 'production' # O 'development' según tu entorno

every 1.day, at: '4:30 am' do
  runner 'UpdatePhoto.update_peces'
  runner 'UpdatePhoto.update_enciclo'
  
end