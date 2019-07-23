#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Pone los valores de la CNP y las zonas basandose en la tabla propiedades y criterios


Usage:

  rails r tools/peces/cnp.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


@criterio = [
    {'Con potencial de desarrollo' => 128, 'Máximo aprovechamiento permisible' => 129, 'En deterioro' => 130, 'No se distribuye' => 131, 'Estatus no definido' => 132},
    {'Con potencial de desarrollo' => 133, 'Máximo aprovechamiento permisible' => 134, 'En deterioro' => 135, 'No se distribuye' => 136, 'Estatus no definido' => 137},
    {'Con potencial de desarrollo' => 138, 'Máximo aprovechamiento permisible' => 139, 'En deterioro' => 140, 'No se distribuye' => 141, 'Estatus no definido' => 142},
    {'Con potencial de desarrollo' => 143, 'Máximo aprovechamiento permisible' => 144, 'En deterioro' => 145, 'No se distribuye' => 146, 'Estatus no definido' => 147},
    {'Con potencial de desarrollo' => 148, 'Máximo aprovechamiento permisible' => 149, 'En deterioro' => 150, 'No se distribuye' => 151, 'Estatus no definido' => 152},
    {'Con potencial de desarrollo' => 153, 'Máximo aprovechamiento permisible' => 154, 'En deterioro' => 155, 'No se distribuye' => 156, 'Estatus no definido' => 157}
]

def leeCSV
  borra_relaciones
  #borra_propiedades

  CSV.foreach(Rails.root.join('db', 'peces', 'cnp.csv'), :col_sep => "@") do |row|
    Rails.logger.debug "Fila con especie_id: #{row[12]}" if OPTS[:debug]
    next unless row[12].present?
    pez = comprueba_pez(row[12].to_i)
    guarda_relaciones(pez, row)
    guarda_propiedades(pez)
  end
end

def comprueba_pez(especie_id)
  begin
    Pez.find(especie_id)
  rescue
    guarda_pez(especie_id)
  end
end

def guarda_pez(especie_id)
  Rails.logger.debug "\tEl pez no existia **************" if OPTS[:debug]
  pez = Pez.new
  pez.especie_id = especie_id
  pez.save
  pez
end

def borra_relaciones
  Rails.logger.debug "\tBorra relaciones anteriores" if OPTS[:debug]
  PezCriterio.where(criterio_id: @criterio.map(&:values).flatten).delete_all
end

def borra_propiedades
  Rails.logger.debug "\tBorra propiedades anteriores" if OPTS[:debug]
  PezPropiedad.where(propiedad_id: (311..316).to_a).delete_all
end

def guarda_relaciones(pez, row)
  6.times do |t|
    pc = pez.peces_criterios.new
    pc.criterio_id = @criterio[t][row[t*2].strip]
    Rails.logger.debug "\tGuarda la relacion: #{t}-#{row[t*2].strip}" if OPTS[:debug] if pc.save
  end
end

def guarda_propiedades(pez)
  propiedades = (311..316).to_a

  propiedades.each do |p|
    pp = pez.peces_propiedades.new
    pp.propiedad_id = p
    Rails.logger.debug "\tGuarda la propiedad: #{p}" if OPTS[:debug] if pp.save
  end
end

start_time = Time.now

leeCSV

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]