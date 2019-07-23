#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Pone el tipo de veda, y veda_fechas basandose en la tabla propiedades y criterios


Usage:

  rails r tools/peces/tipo_de_veda.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


@criterio = {'Permanente' => 21, 'Temporal fija' => 22, 'Temporal variable' => 23, 'Sin veda' => 126, 'Sin datos' => 127}

def leeCSV
  borra_relaciones

  CSV.foreach(Rails.root.join('db', 'peces', 'tipo_de_veda.csv'), :col_sep => "@") do |row|
    Rails.logger.debug "Fila con especie_id: #{row[4]}" if OPTS[:debug]
    next unless row[4].present?
    pez = comprueba_pez(row[4].to_i)
    guarda_relacion(pez, row)
    guarda_valores_adicionales(pez, row)
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
  ids = @criterio.values
  PezCriterio.where(criterio_id: ids).delete_all
end

def guarda_relacion(pez, row)
  pc = pez.peces_criterios.new
  pc.criterio_id = @criterio[row[0].strip]
  Rails.logger.debug "\tGuarda la relacion" if OPTS[:debug] if pc.save
end

def guarda_valores_adicionales(pez, row)
  pez.veda_fechas = nil
  veda_fechas = "#{row[2]},#{row[3]}".strip

  if veda_fechas != ','
    pez.veda_fechas = veda_fechas
  end

  pez.guardar_manual = true
  Rails.logger.debug "\tGuarda el valor adicional de veda_fechas" if OPTS[:debug] if pez.save
end

start_time = Time.now

leeCSV

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]