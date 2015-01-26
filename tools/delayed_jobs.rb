##########ACTUALMENTE NO SE UTILIZA##########
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
*** Este script crea la tabla delayed_jobs para todas las bases o para las especificadas

Usage:

  rails r tools/delayed_jobs.rb -d create    #para crear la tabla en todas las bases
  rails r tools/delayed_jobs.rb -d drop      #para borrar la tabla en todas las bases

  rails r tools/delayed_jobs.rb -d create 03-Hongos-Sept14    #para crear la tabla en una o mas bases en especifico
  rails r tools/delayed_jobs.rb -d drop 03-Hongos-Sept14      #para borrar la tabla en una o mas bases en especifico
where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def argumento_a_tabla(arg)
  puts "Argumento con: #{arg}" if OPTS[:debug]
  sql = index = ''
  if arg == 'create'
    sql+= 'CREATE TABLE delayed_jobs'
    sql+= '('
    sql+= 'id INT IDENTITY PRIMARY KEY,'
    sql+= 'priority INT NOT NULL DEFAULT 0,'
    sql+= 'attempts INT NOT NULL DEFAULT 0,'
    sql+= 'handler TEXT NOT NULL,'
    sql+= 'last_error  TEXT,'
    sql+= 'run_at DATETIME,'
    sql+= 'locked_at DATETIME,'
    sql+= 'failed_at DATETIME,'
    sql+= 'locked_by NVARCHAR(255),'
    sql+= 'queue NVARCHAR(255),'
    sql+= 'updated_at DATETIME,'
    sql+= 'created_at DATETIME,'
    sql+= ')'

    index+= 'CREATE NONCLUSTERED INDEX delayed_jobs_priority_run_at '
    index+= 'ON delayed_jobs (priority, run_at)'

    ActiveRecord::Base.connection.execute(sql)
    ActiveRecord::Base.connection.execute(index)
  else
    sql+= 'DROP TABLE delayed_jobs'
    ActiveRecord::Base.connection.execute(sql)
  end
end


start_time = Time.now

acciones = %w(create drop)                #posibles acciones
if ARGV.any? && acciones.include?(ARGV[0].downcase)
  if ARGV.count > 1
    ARGV.each_with_index do |base, index|
      next if index == 0
      if CONFIG.bases.include?(base)
        ActiveRecord::Base.establish_connection base
        puts "Con base: #{base}" if OPTS[:debug]
        argumento_a_tabla(ARGV[0].downcase)
      end
    end
  elsif ARGV.count == 1
    CONFIG.bases.each do |base|
      ActiveRecord::Base.establish_connection base
      puts "Con base: #{base}" if OPTS[:debug]
      argumento_a_tabla(ARGV[0].downcase)
    end
  end
end

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]