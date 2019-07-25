class GeoAtopo

  # Guarda el topo json de la region seleccionada, posibles valores son: estado municipio anp ecorregion
  def topojson_por_region(region)
    return nil unless %w(estado municipio anp ecorregion).include?(region)
    Rails.logger.debug "[DEBUG] - Generando los topojson con region: #{region}"

    ruta = Rails.root.join('public', 'topojson')
    Dir.mkdir(ruta) unless File.exists?(ruta)
    geojson_todos = {type: 'FeatureCollection', features: []}  # Para todos loes estados o municipios juntos

    "Geoportal::#{region.camelize}".constantize.campos_min.campos_geom.all.each do |reg|
      Rails.logger.debug "[DEBUG] - Generando la región: #{reg.nombre_publico}"

      geojson = {type: 'FeatureCollection', features: []}
      feature = {type: 'Feature', properties:{region_id: reg.region_id, centroide: [reg.lat, reg.long]}, geometry: JSON.parse(reg.geojson)}
      feature[:properties][:nombre_region] = reg.nombre_publico
      #feature[:properties][:bbox] = reg.bbox
      feature[:properties][:tipo] = reg.tipo
      feature[:properties][:tipo_region] = reg.try(:tipo_region)
      geojson[:features] << feature
      geojson_todos[:features] << feature

    end  # End cada region each

    archivo_topo_todos = ruta.join("#{region}.json")
    archivo_geo_todos = ruta.join('collection.json')
    archivo_tmp_todos = ruta.join("#{region}_tmp.json")

    # Escribe a disco el archivo geojson
    File.write(archivo_geo_todos, geojson_todos.to_json)

    # Convierte a topojson
    topojson_todos = dame_topojson_system({q: '1e4', p: '7e-5', i: archivo_geo_todos, o: archivo_topo_todos, tmp: archivo_tmp_todos})
    File.delete(archivo_geo_todos) if File.exist?(archivo_geo_todos)
    Rails.logger.debug "[DEBUG] - Hubo un error al generar la region: #{archivo_topo_todos}" unless topojson_todos

  end

  # Regresa en formato topojson
  def dame_topojson(collection)
    source = open('./lib/assets/topojson.js').read
    ExecJS.runtime = ExecJS::Runtimes::Node
    context = ExecJS.compile(source)

    context.eval("topojson.topology({collection: #{collection} }, 1e4)")
  end

  # Devuelve el topojson con un comando de linux
  def dame_topojson_system(opc = {})
    res = system("geo2topo -q #{opc[:q]} #{opc[:i]} > #{opc[:tmp]}")

    if res
      res = system("toposimplify -p #{opc[:p]} #{opc[:tmp]} > #{opc[:o]}")
    end

    File.delete(opc[:tmp])
    res
  end
end