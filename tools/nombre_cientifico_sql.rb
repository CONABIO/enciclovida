require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo ancestry_ascendente_directo.

*** Este script tiene que correrse cada vez que se ingresa una nueva base.


Usage:

  rails r tools/ancestry_ascendente_directo_sql.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

ActiveRecord::Base.establish_connection CONFIG.bases.first
CONFIG.bases.each do |base|
  ActiveRecord::Base.establish_connection base
  puts "Conectando a: #{base}" if OPTS[:debug]
#antes de correr se tiene que comentar la linea de ancestry en el model

  Nombre.all.each do |taxon|
    if taxon.depth == 7
      generoID=taxon.ancestry_acendente_obligatorio.split("/")[5]
      genero=Especie.find(generoID).nombre
      taxon.nombre_cientifico="#{genero} #{taxon.nombre}"
    elsif taxon.depth == 8
      generoID=taxon.ancestry_acendente_obligatorio.split("/")[5]
      genero=Especie.find(generoID).nombre
      especieID=taxon.ancestry_acendente_obligatorio.split("/")[6]
      especie=Especie.find(especieID).nombre
      taxon.nombre_cientifico="#{genero} #{especie} #{taxon.nombre}"
    else
      taxon.nombre_cientifico="#{taxon.nombre}"
    end
    taxon.save
  end
end
