class GeoATopo

  # Guarda el topo json de la region seleccionada, posibles valores son: estado municipio anp ecorregion
  def topojson_por_region(region)
    return nil unless %w(estado municipio anp ecorregion).include?(region)
    Rails.logger.debug "[DEBUG] - Generando los topojson con region: #{region}"

    ruta = Rails.root.join('public', 'topojson')
    Dir.mkdir(ruta) unless File.exists?(ruta)
    geojson_todos = { type: 'FeatureCollection', features: [] }  # Para todos loes estados o municipios juntos

    Geoportal.const_get(region.camelize).campos_min.campos_geom.all.each do |reg|
      Rails.logger.debug "\t[DEBUG] - Generando la región: #{reg.nombre_publico}"
      bounds = reg.bounds.gsub(/[BBOX()]/,'').split(',').map{ |a| a.split(' ').reverse.map{ |s| s.to_f } }

      feature = { type: 'Feature', properties: { region_id: reg.region_id, nombre_region: reg.nombre_publico, tipo_region: reg.tipo, bounds: bounds }, geometry: JSON.parse(reg.geojson) }

      #geojson[:features] << feature
      geojson_todos[:features] << feature

    end  # End cada region each

    archivo_topo_todos = ruta.join("#{region}.topojson")
    archivo_geo_todos = ruta.join('collection.json')
    archivo_tmp_todos = ruta.join("#{region}_tmp.json")

    # Escribe a disco el archivo geojson
    File.write(archivo_geo_todos, geojson_todos.to_json)

    # Convierte a topojson y simplifica, originalmente q tenia un valor de: 1e4
    topojson_todos = dame_topojson_system({q: '0', p: '7e-5', i: archivo_geo_todos, o: archivo_topo_todos, tmp: archivo_tmp_todos})
    File.delete(archivo_geo_todos) if File.exist?(archivo_geo_todos)
    Rails.logger.debug "\t[DEBUG] - Hubo un error al generar la region: #{archivo_topo_todos}" unless topojson_todos

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