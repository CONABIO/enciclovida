#! /usr/local/bin/ruby
require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Pone la procedencia basandose en la tabla propiedades y criterios


Usage:

  rails r tools/peces/procedencia.rb -d     #para crear los campos adicionales en todas las bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end


@criterio = {'Nacional' => 4, 'Importado' => 5, 'Nacional e Importado' => 6}

def leeCSV
  CSV.foreach(Rails.root.join('db', 'peces', 'procedencia.csv'), :col_sep => "@") do |row|
    puts "Fila con especie_id: #{row[2]}" if OPTS[:debug]
    next unless row[2].present?
    pez = comprueba_pez(row[2].to_i)
    borra_procedencias(row)
    guarda_procedencia(pez, row)
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
  puts "\tEl pez no existia **************" if OPTS[:debug]
  pez = Pez.new
  pez.especie_id = especie_id
  pez.save
  pez
end

def borra_procedencias(row)
  puts "\tBorra procedencias anteriores" if OPTS[:debug]
  PezCriterio.where(especie_id: row[2], criterio_id: @criterio.values).delete_all
end

def guarda_procedencia(pez, row)
  pc = pez.peces_criterios.new
  pc.criterio_id = @criterio[row[0]]

  begin
  puts "\tGuarda la procencia" if OPTS[:debug] if pc.save
  rescue
    puts "\tEste record ya existia" if OPTS[:debug] if pc.save
  end
end

start_time = Time.now

leeCSV

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]