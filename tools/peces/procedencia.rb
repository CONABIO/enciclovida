#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Pone la procedencia basandose en la tabla propiedades y criterios


Usage:

  rails r tools/peces/procedencia.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


@criterio = {'Nacional' => 4, 'Importado' => 5, 'Nacional e Importado' => 6}

def leeCSV
  borra_relaciones

  CSV.foreach(Rails.root.join('db', 'peces', 'procedencia.csv'), :col_sep => "@") do |row|
    Rails.logger.debug "Fila con especie_id: #{row[2]}" if OPTS[:debug]
    next unless row[2].present?
    pez = comprueba_pez(row[2].to_i)
    guarda_relacion(pez, row)
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
  PezCriterio.where(criterio_id: @criterio.values).delete_all
end

def guarda_relacion(pez, row)
  pc = pez.peces_criterios.new
  pc.criterio_id = @criterio[row[0].strip]
  Rails.logger.debug "\tGuarda la relacion" if OPTS[:debug] if pc.save
end

start_time = Time.now

leeCSV

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]