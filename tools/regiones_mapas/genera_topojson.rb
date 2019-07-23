OPTS = Trollop::options do
  banner <<-EOS

*** Guarda debajo de public los topojson generados de todas las regiones del SNIB, esto solo lo hará una vez,
ya que despues los consultará bajo demanda

Usage:

  rails r tools/regiones_mapas/genera_topojson.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

# Guarda el topo json de cada region y las divisiones politicas
def topojson_por_region
  Rails.logger.debug 'Generando los topojson por region' if OPTS[:debug]

  #regiones = %w(estado municipio anp ecorregion)
  regiones = %w(anp)
  ruta = Rails.root.join('public', 'topojson')
  Dir.mkdir(ruta) unless File.exists?(ruta)

  regiones.each do |region|  # Itera sobre los 4 tipos de region, para generar cada uno
    Rails.logger.debug "\tGenerando con el tipo de región: #{region}" if OPTS[:debug]
    topo = GeoATopo.new
    geojson_todos = {type: 'FeatureCollection', features: []}  # Para todos loes estados o municipios juntos

    region.camelize.constantize.campos_min.campos_geom.all.each do |reg|
      Rails.logger.debug "\t\tGenerando la región: #{reg.nombre_region}" if OPTS[:debug]

      geojson = {type: 'FeatureCollection', features: []}
      feature = {type: 'Feature', properties:{region_id: reg.region_id, centroide: [reg.lat, reg.long]}, geometry: JSON.parse(reg.geojson)}

      case region
        when 'estado'
          feature[:properties][:nombre_region] = I18n.t("estados.#{reg.nombre_region.estandariza}")
        when 'municipio'
          estado_id = Estado::CORRESPONDENCIA.index(reg.parent_id)
          estado_nombre = I18n.t("estados.#{Estado.find(estado_id).entidad.estandariza}")
          feature[:properties][:nombre_region] = "#{reg.nombre_region}, #{estado_nombre}"
          feature[:properties][:parent_id] = reg.parent_id
          feature[:properties][:region_id_se] = reg.region_id_se
        when 'anp'
          feature[:properties][:nombre_region] = "#{reg.nombre_region}, ANP"
        else
          feature[:properties][:nombre_region] = reg.nombre_region
      end

      geojson[:features] << feature
      geojson_todos[:features] << feature

=begin
      if region == 'municipio'
        archivo_topo = ruta.join("#{region}_#{reg.region_id}_#{reg.parent_id}.json")
        archivo_geo = ruta.join("#{region}_#{reg.region_id}_#{reg.parent_id}_geo.json")
        archivo_tmp = ruta.join("#{region}_#{reg.region_id}_#{reg.parent_id}_tmp.json")
      else
        archivo_topo = ruta.join("#{region}_#{reg.region_id}.json")
        archivo_geo = ruta.join("#{region}_#{reg.region_id}_geo.json")
        archivo_tmp = ruta.join("#{region}_#{reg.region_id}_tmp.json")
      end
=end

      # Escribe a disco el archivo geojson
      #File.write(archivo_geo, geojson.to_json)

      # Convierte a topojson
      #topojson = topo.dame_topojson_system({q: '1e4', p: '7e-8', i: archivo_geo, o: archivo_topo, tmp: archivo_tmp})
      #Rails.logger.debug "Hubo un error al generar el municipio: #{archivo_topo}" if OPTS[:debug] && !topojson
    end  # End cada region each

    archivo_topo_todos = ruta.join("#{region}.json")
    archivo_geo_todos = ruta.join('collection.json')
    archivo_tmp_todos = ruta.join("#{region}_tmp.json")

    # Escribe a disco el archivo geojson
    File.write(archivo_geo_todos, geojson_todos.to_json)

    if %w(estado anp).include?(region)
      # Convierte a topojson
      topojson_todos = topo.dame_topojson_system({q: '1e4', p: '7e-8', i: archivo_geo_todos, o: archivo_topo_todos, tmp: archivo_tmp_todos})
      Rails.logger.debug "Hubo un error al generar la region: #{archivo_topo_todos}" if OPTS[:debug] && !topojson_todos
    end

  end  # End tipos regiones each
end

# Carga una division municipal por estado
def topojson_municipios_por_estado
  Rails.logger.debug 'Generando los municipios por estado' if OPTS[:debug]
  topo = GeoATopo.new
  ruta = Rails.root.join('public', 'topojson')
  Dir.mkdir(ruta) unless File.exists?(ruta)

  Estado.campos_min.all.each do |e|
    Rails.logger.debug "Generando con estado: #{e.nombre_region}" if OPTS[:debug]
    geojson = {type: 'FeatureCollection', features: []}  # Para todos loes estados o municipios juntos
    estado_id = Estado::CORRESPONDENCIA[e.region_id]
    estado_nombre = I18n.t("estados.#{e.nombre_region.estandariza}")

    Municipio.campos_min.campos_geom.where(cve_ent: estado_id).each do |m|
      Rails.logger.debug "\tGenerando con municipio: #{m.nombre_region}" if OPTS[:debug]
      feature = {type: 'Feature', properties:{}}
      feature[:properties][:region_id] = m.region_id
      feature[:properties][:nombre_region] = "#{m.nombre_region}, #{estado_nombre}"
      feature[:properties][:parent_id] = m.parent_id
      feature[:properties][:centroide] = [m.lat, m.long]
      feature[:properties][:region_id_se] = m.region_id_se
      feature[:geometry] = JSON.parse(m.geojson)
      geojson[:features] << feature
    end

    archivo_topo = ruta.join("estado_#{e.region_id}_division_municipal.json")
    archivo_geo = ruta.join('collection.json')
    archivo_tmp = ruta.join("estado_#{e.region_id}_division_municipal_tmp.json")

    # Escribe a disco el archivo geojson
    File.write(archivo_geo, geojson.to_json)

    # Convierte a topojson
    topojson = topo.dame_topojson_system({q: '1e4', p: '7e-8', i: archivo_geo, o: archivo_topo, tmp: archivo_tmp})
    Rails.logger.debug "Hubo un error al generar el municipio: #{archivo_topo}" if OPTS[:debug] && !topojson
  end
end

start_time = Time.now

topojson_por_region
topojson_municipios_por_estado

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]