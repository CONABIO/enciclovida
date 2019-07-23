require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS

*** Completa el numero de taxones de determinada categoria, favor de revisar cual categoria se
desea hacer el conteo http://www.conabio.gob.mx/biotica5/documents/Diccionario%20de%20datos.pdf
ej. si se necesita contar el número de especies: se pasarán los niveles de la categoria como parametros parámetros: 7 _ 0 0
Solo admite 4 parámetros, pueden ser númericos u ocupar el "_" que indica cualquier digito

Usage:

  rails r tools/categorias_conteo.rb -d 7 _ 0 0

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def conteo
  Especie.find_each do |taxon|
    Rails.logger.debug "#{taxon.id}-#{taxon.nombre}" if OPTS[:debug]

    ancestry = taxon.is_root? ? "#{taxon.id}/%" : "#{taxon.ancestry_ascendente_directo}/#{taxon.id}%"
    conteo = Especie.where("ancestry_ascendente_directo LIKE '#{ancestry}'").
        where(estatus: 2).where(@where_niveles.join(' AND ')).categoria_taxonomica_join.count

    next unless conteo > 0

    # Solo las especies
    categoria_conteo = CategoriaConteo.where(especie_id: taxon.id, categoria: '7_00')

    if categoria_conteo.length == 1
      categoria_conteo = categoria_conteo.first
      categoria_conteo.conteo = conteo

    elsif categoria_conteo.length == 0
      categoria_conteo = CategoriaConteo.new(especie_id: taxon.id, conteo: conteo, categoria: ARGV.join(''))

    else
      Rails.logger.debug "\tError: existe más de un conteo para ese taxón" if OPTS[:debug]
      next
    end

    if categoria_conteo.changed?
      categoria_conteo.save
      Rails.logger.debug "\tConteo: #{conteo} de los niveles: #{ARGV.join('')} " if OPTS[:debug]
    end

  end
end


start_time = Time.now

if ARGV.count == 4
  @where_niveles = []

  ARGV.each_with_index do |nivel, index|
    regexp = nivel =~ /^[0-7]$|^_$/

    if regexp.nil?
      Rails.logger.debug 'Los parámetros son incorrectos, favor de revisar la documentación' if OPTS[:debug]
      exit
    else
      next if nivel == '_'
      @where_niveles << "nivel#{index+1}=#{nivel}"
    end
  end

  conteo
else
  Rails.logger.debug 'Los parámetros son incorrectos, favor de revisar la documentación' if OPTS[:debug]
end

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]