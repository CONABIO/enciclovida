#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'
require 'tiny_tds'

OPTS = Trollop::options do
  banner <<-EOS
Pone los campos que hacen falta en las tablas correspondientes, para cada base.

*** Este script puede usuarse para crear los campos adicionales o quitarlos.


Usage:

  rails r tools/atributos_adicionales.rb -d     #por default crea los campos adicionales
  rails r tools/atributos_adicionales.rb -d drop    #para borrar los campos adicionales

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

client = TinyTds::Client.new(:username => 'VIRTUALW8\beto', :password => '123', :host => '172.16.3.224', :port => '5050')

puts client.dead?    # => false
puts client.closed?  # => false
puts client.active?  # => true

queryNombreBD = "select	substring(name,1,2) as ID, name as bd from sys.databases where name like '[0-9]%' order by name"

equivalencia = {
    'bibliografias' => 'Bibliografia',
    'catalogos' => 'CatalogoNombre',
    'categorias_taxonomicas' => 'CategoriaTaxonomica',
    'especies' => 'Nombre',
    'especies_bibliografias' => 'RelNombreBiblio',
    'especies_catalogos' => 'RelNombreCatalogo',
    'especies_estatuses' => 'Nombre_Relacion',
    'especies_estatuses_bibliografias' => 'RelacionBibliografia',
    'especies_regiones' => 'RelNombreRegion',
    'estatuses' => 'Tipo_Relacion',
    'nombres_comunes' => 'Nomcomun',
    'nombres_regiones' => 'RelNomNomComunRegion',
    'nombres_regiones_bibliografias' => 'RelNomNomcomunRegionBiblio',
    'regiones' => 'Region',
    'tipos_distribuciones' => 'TipoDistribucion',
    'tipos_regiones' => 'TipoRegion',
}

adicionales = {
    'especies' =>
        {
            'nombre_cientifico' =>  'varchar(255) NULL,',
            'ancestry_ascendente_directo' => 'varchar(255) NULL,',
            'ancestry_ascendente_obligatorio' => 'varchar(255) NULL,',
            'nombre_comun_principal' => 'varchar(255) NULL,',
            'foto_principal' => 'varchar(255) NULL,',
        }
}

res = client.execute(queryNombreBD)
res.to_json      #con esto puedo seguir utilizando res sin cancelar la conexion, bug

res.each do |bd|
  puts "Con base: #{bd['bd']}" if OPTS[:debug]
  query= ''

  adicionales.each do |tabla, campos|
    if ARGV.any? { |e| e.downcase.include?('drop') }
      puts 'Ejecutando con argumento: DROP' if OPTS[:debug]
      query+= "ALTER TABLE [#{bd['bd']}].dbo.#{equivalencia[tabla]} DROP COLUMN "

      campos.each do |campo, valor|
        query+= "#{campo},"
      end

    else
      puts 'Ejecutando con argumento: ADD (default)' if OPTS[:debug]
      query+= "ALTER TABLE [#{bd['bd']}].dbo.#{equivalencia[tabla]} ADD "

      campos.each do |campo, valor|
        query+= "#{campo} #{valor}"
      end
    end
  end

  puts "Query: #{query[0..-2]}" if OPTS[:debug]
  resul = client.execute(query[0..-2])
  resul.cancel
end

res.cancel
client.close
