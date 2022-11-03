require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS

*** Exporta en un archivo las especies que no tienen ninguna ficha, para los curadores de fichas

Usage: 
  rails r tools/enciclovida/sin_ficha.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def taxa_sin_ficha
  datos = {}
  #continuar = false
  EspecieEstadistica.where(estadistica_id: 1).order(conteo: :desc).limit(5000).each do |est|
    #continuar = true if est.especie_id == 159930
    #next unless continuar
    Rails.logger.debug "---Corriendo con especie_id: #{est.especie_id}" if OPTS[:debug]
    doc = Nokogiri::HTML(URI.open("http://localhost:3000/especies/#{est.especie_id}/descripcion"))

    begin
      tipo_ficha = doc.xpath('//select[@id="from"]/option[@selected="selected"]').attr('value').content.estandariza
      datos[est.especie_id] = tipo_ficha
      Rails.logger.debug "\tTipo ficha: #{tipo_ficha}" if OPTS[:debug]
    rescue => e
      Rails.logger.debug "\tERROR DE URI: #{est.especie_id} - #{e.inspect}" if OPTS[:debug]
    end

  end

  Rails.logger.debug datos if OPTS[:debug]
  guarda_csv(datos)
end

def guarda_csv(datos)
  Rails.logger.debug "Generando el CSV ..." if OPTS[:debug]

  encabezado = ['Especie ID', 'Tipo ficha', 'Nombre científico', "Nombre común", "Categoría taxonómica", "Enciclovida URL"]
  taxones = Especie.datos_basicos.where(id: datos.keys).joins(:especie_estadisticas).where("estadistica_id=1").order("conteo DESC").map{|e| [e.id, datos[e.id], e.nombre_cientifico, e.nombre_comun_principal, e.nombre_categoria_taxonomica, "https://enciclovida.mx/especies/#{e.id}-#{e.nombre_cientifico.estandariza}"] }
  
  ruta_csv = Rails.root.join('tmp', 'sin_ficha')
  FileUtils.mkpath(ruta_csv, :mode => 0755) unless File.exists?(ruta_csv)
  archivo_csv = ruta_csv.join(Time.now.strftime("%Y-%m-%d_%H-%M-%S").to_s + '.csv')

  CSV.open(archivo_csv, "wb") do |csv|
    csv << encabezado

    taxones.each do |t|
      csv << t
    end
  end
end


start_time = Time.now

taxa_sin_ficha

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]