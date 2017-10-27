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

def guarda_topojson
  puts 'Generando los topojson' if OPTS[:debug]

  #regiones = %w(estado municipio anp ecorregion)
  regiones = %w(estado)
  ruta = Rails.root.join('public', 'topojson')
  Dir.mkdir(ruta) unless File.exists?(ruta)

  regiones.each do |region|  # Itera sobre los 4 tipos de region
    puts "\tGenerando con el tipo de región: #{region}" if OPTS[:debug]
    topo = GeoATopo.new
    geojson_region = {type: 'FeatureCollection', features: []}  # Para todos loes estados o municipios juntos

    region.camelize.constantize.select('ST_AsGeoJSON(the_geom) AS geojson').campos_min.all.each do |reg|
      puts "\t\tGenerando la región: #{reg.nombre_region}" if OPTS[:debug]

      geojson = {type: 'FeatureCollection', features: []}
      feature = {type: 'Feature', properties:{nombre_region: reg.nombre_region}, geometry: JSON.parse(reg.geojson)}
      geojson[:features] << feature
      geojson_region[:features] << feature
      topojson = topo.dame_topojson(geojson.to_json)

      archivo = if region == 'municipio'
                  ruta.join("#{region}_#{reg.region_id}_#{reg.parent_id}.json")
                else
                  ruta.join("#{region}_#{reg.region_id}.json")
                end

      File.write(archivo, topojson.to_json)
    end  # End cada region each

    topojson = topo.dame_topojson(geojson_region.to_json)
    File.write(ruta.join("#{region}.json"), topojson.to_json)
  end  # End tipos regiones each
end


start_time = Time.now

guarda_topojson

puts "Termino en #{Time.now - start_time} seg" if OPTS[:debug]