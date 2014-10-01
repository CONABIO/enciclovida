require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Completa el campo nombre_cientifico .

*** Este script completa el nombre cientifico de acuerdo a la categoria taxonomica
Correr despues de tener el campo ancestry_ascendente_obligatorio listo

Usage:

  rails r tools/nombre_cientifico_sql.rb -d
  rails r tools/nombre_cientifico_sql.rb -d 02-Arthropoda    #para correr solo un conjunto de bases

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def completa
  EspecieBio.find_each do |taxon|
    puts taxon.nombre if OPTS[:debug]
    case I18n.transliterate(taxon.categoria_taxonomica.nombre_categoria_taxonomica).downcase
      when 'especie'
        taxon.nombre_cientifico = "#{encuentra_genero(taxon, 'genero')} #{taxon.nombre}"
      when 'subespecie', 'variedad', 'forma'
        taxon.nombre_cientifico = "#{encuentra_genero(taxon, 'genero')} #{encuentra_genero(taxon, 'especie')} #{taxon.nombre}"
      when 'subvariedad'
        taxon.nombre_cientifico = "#{encuentra_genero(taxon, 'genero')} #{encuentra_genero(taxon, 'especie')} #{encuentra_genero(taxon, 'variedad')} #{taxon.nombre}"
      when 'subforma'
        taxon.nombre_cientifico = "#{encuentra_genero(taxon, 'genero')} #{encuentra_genero(taxon, 'especie')} #{encuentra_genero(taxon, 'forma')} #{taxon.nombre}"
      else
        taxon.nombre_cientifico = taxon.nombre
    end
    taxon.save
    puts "  #{taxon.nombre_cientifico}" if OPTS[:debug]
  end
end

def encuentra_genero(taxon, cat)
  taxon.ancestor_ids.reverse.each do |a|
    tax = EspecieBio.find(a)
    return tax.nombre if I18n.transliterate(tax.categoria_taxonomica.nombre_categoria_taxonomica).downcase == cat
  end
end

if ARGV.any?
  ARGV.each do |base|
    if CONFIG.bases.include?(base)
      ActiveRecord::Base.establish_connection base
      puts "Conectando a: #{base}" if OPTS[:debug]
      completa
    end
  end
else
  CONFIG.bases.each do |base|
    ActiveRecord::Base.establish_connection base
    puts "Conectando a: #{base}" if OPTS[:debug]
    completa
  end
end