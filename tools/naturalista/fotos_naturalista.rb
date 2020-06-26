require 'rubygems'
require 'trollop'
require 'rest_client'
require 'json'

OPTS = Trollop::options do
  banner <<-EOS
Importa las fotos de proveedores hacia la tabla photos y taxon_photos.

*** En caso de estar en SQL Server, el volcado de tablas es necesario para esta accion
Usage:

  rails r tools/fotos_naturalista.rb -d              #Llena photos y taxon_photos respectivamente
  rails r tools/fotos_naturalista.rb -d truncate     #Hace un TRUCATE a  photos y taxon_photos (OJO en real)

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def busca_fotos
  # Empeizo por proveedores para no correr todos los taxones
  Proveedor.where("naturalista_info IS NOT NULL OR naturalista_info != ''").find_each do |proveedor|
    Rails.logger.debug proveedor.id if OPTS[:debug]
    proveedor.fotos(@usuario.id)
  end
end

def truncate_tables
  sql = ['TRUNCATE TABLE photos', 'TRUCATE TABLE taxon_photos']
  sql.each do |sql|
    Bases.ejecuta(sql)
  end
end

def system_call(cmd)
  Rails.logger.debug "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end


start_time = Time.now

if ARGV.length == 1 && ARGV.first.present? && ARGV.first.downcase == 'truncate'
  Rails.logger.debug "Con comando: #{ARGV.first}" if OPTS[:debug]
  truncate_tables
  system_call('rake tmp:cache:clear')
elsif ARGV.blank?
  Rails.logger.debug "Con comando default para crear: #{ARGV.first}" if OPTS[:debug]
  exit(0) unless @usuario = Usuario.where(:usuario => CONFIG.usuario.to_s).first
  busca_fotos
else
  exit(0)
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]
