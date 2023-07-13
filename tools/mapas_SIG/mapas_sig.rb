require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Marca en la base de proveedores las especies que tienen mapa de distribución, de acuerdo al 
archivo que envia el SIG, idealmente deberia ser un API ...
Columnas requeridas: idCAT, styler, layers, bbox, mapa, anio, autor

Usage:

  rails r tools/mapas_SIG/mapas_sig.rb -d /ruta/del/archivo

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

@row = nil

def asigna_mapa_sig
  return { idCAT: @row['idCAT'], estatus: false, error: 'idCAT está vacío' } unless @row['idCAT'].present?
  scat = Scat.where(catalogo_id: @row['idCAT']).first
  return { idCAT: @row['idCAT'], estatus: false, error: 'No existe el idCAT en Scat' } unless scat
  taxon = scat.especie
  return { idCAT: @row['idCAT'], estatus: false, error: 'No existe el taxon en especie' } unless taxon
  return { idCAT: @row['idCAT'], estatus: false, error: 'No es una especie o inferior' } unless taxon.especie_o_inferior?
  nombre_cientifico = taxon.nombre_cientifico

  # Para que las subespecies e inferiores estes vinculadas a su especie
  if CategoriaTaxonomica::CATEGORIAS_INFRAESPECIES.include?(taxon.categoria_taxonomica.nombre_categoria_taxonomica)
    nombre_cientifico = taxon.nombre_cientifico  # El nombre de la subespecie antes de poner el de la especie
    taxon = Especie.where(id: taxon.id_ascend_obligatorio).first
  end

  taxon_valido = taxon.dame_taxon_valido
  return { idCAT: @row['idCAT'], estatus: false, error: 'No existe el taxon válido' } unless taxon_valido

  bbox = @row['bbox'].split(',')
  bbox_orden = "#{bbox[1]},#{bbox[0]},#{bbox[3]},#{bbox[2]}"

  { estatus: true, taxon: taxon_valido, idCAT: @row['idCAT'], nombre_cientifico: nombre_cientifico, layers: @row['layers'], styles: @row['styler'], bbox: bbox_orden, anio: @row['anio'], autor: @row['autor'] }
end

# Guarda en la base lo que resulto de la asignacion de geoserver_info
def guarda_geoserver_info(v)
  return unless v[:estatus]
  t = v[:taxon]

  if p = t.proveedor
    geoserver_info = asigna_geoserver_info(v, p.geoserver_info)
    p.geoserver_info = geoserver_info
    p.save if p.changed?
  else
    geoserver_info = asigna_geoserver_info(v)
    p = Proveedor.new({ especie_id: t.id, geoserver_info: geoserver_info })
    p.save
  end

end

# Asigna el valor y el acomodo de geoserver_info
def asigna_geoserver_info(v, geoserver_info=nil)
  geo = {}

  if geoserver_info.present?
    begin
      geo = JSON.parse(geoserver_info)
      geo["Mapa #{geo.count + 1}"] = { nombre_cientifico: v[:nombre_cientifico], layers: v[:layers], styles: v[:styles], bbox: v[:bbox], anio: v[:anio], autor: v[:autor] }
    rescue
      nil
    end
  else
    geo['Mapa 1'] = { nombre_cientifico: v[:nombre_cientifico], layers: v[:layers], styles: v[:styles], bbox: v[:bbox], anio: v[:anio], autor: v[:autor] }
  end

  geo.to_json
end

def limpia_geoserver_info
  Proveedor.update_all(geoserver_info: nil)
end

def lee_csv(csv_path)
  CSV.foreach(csv_path, :headers => true) do |r|
    @row = r

    Rails.logger.debug "\tID: #{@row['idCAT']}" if OPTS[:debug]
    v = asigna_mapa_sig
    guarda_geoserver_info(v)
  end
end


Rails.logger.debug "Iniciando el script ..." if OPTS[:debug]
start_time = Time.now

if ARGV.present? && ARGV.any? && ARGV.length == 1

  if File.exist?(ARGV[0])
    limpia_geoserver_info
    lee_csv(ARGV[0])
  else
    Rails.logger.debug "\tEl archivo: #{ARGV[0]}, no existe." if OPTS[:debug]
  end

end

Rails.logger.debug "Terminó en #{Time.now - start_time} seg" if OPTS[:debug]
