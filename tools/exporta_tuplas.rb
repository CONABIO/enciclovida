require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Exporta todas las tuplas de la base a un archivo llamado:
seeds_aaaa_mm_dd_hhmm.rb para que se puedan hacer pruebas con la base original.
Antes de correr el script, es necesario que la base este completamente vacia y con los ultimos cambios de migraciones

rake db:drop
rake db:setup

Usage:

  rails r tools/exporta_tuplas.rb

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def system_call(cmd)
  puts "Ejecutando ... #{cmd}" if OPTS[:debug]
  system cmd
end

def export_model
  comando_seed='rake db:seed:dump MODELS='
  modelos_sin_respaldo=%w(ActiveRecord::SessionStore::Session Delayed::Backend::ActiveRecord::Job)

  comando_seed+= ActiveRecord::Base.descendants.map(&:name).map{|m| modelos_sin_respaldo.include?(m) ? nil : m}.compact.join(',')
  puts comando_seed
  #system_call(comando_seed[0..-2])
end

Rails.application.eager_load!
start_time = Time.now
date_file=start_time.strftime '%Y_%m_%d_%H%M'

Trollop::die "Lo sentimos el archivo '#{@file_path}' ya existe." unless !File.exists?(@file_path = "db/seeds_#{date_file}.rb")
export_model
puts "Exporto #{@file_path} en #{Time.now - start_time} seg"
