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
  # Empeizo por especies y no por proveedores porque cuando se sustituyan bases algunos taxones
  # pueden haber quedado sin correspondencia
  Especie.find_each do |taxon|
  #Especie.limit(100).each do |taxon|
    puts "#{taxon.id}-#{taxon.nombre_cientifico}" if OPTS[:debug]
    #next unless taxon.id > 7000000
    next unless proveedor = taxon.proveedor
    next unless proveedor.naturalista_info.present?
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
  puts "Ejecutando: #{cmd}" if OPTS[:debug]
  system cmd
end


start_time = Time.now

if ARGV.length == 1 && ARGV.first.present? && ARGV.first.downcase == 'truncate'
  puts "Con comando: #{ARGV.first}" if OPTS[:debug]
  truncate_tables
  system_call('rake tmp:cache:clear')
elsif ARGV.blank?
  puts "Con comando default para crear: #{ARGV.first}" if OPTS[:debug]
  exit(0) unless @usuario = Usuario.where(:usuario => CONFIG.usuario.to_s).first
  busca_fotos
else
  exit(0)
end

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]