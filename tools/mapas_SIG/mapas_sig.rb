require 'rubygems'
require 'trollop'

OPTS = Trollop::options do
  banner <<-EOS
Marca en la base de proveedores las especies que tienen mapa de distribución, de acuerdo al 
archivo que envia el SIG, idealmente deberia ser un webservice ...
Columnas requeridas: id, idcapa, title

Usage:

  rails r tools/mapas_SIG/mapas_sig.rb -d /ruta/del/archivo

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

@row = nil

def actualiza_mapa_sig
  infraesp = %w(subsp. var.)

  año = @row['title'][-5,4].numeric? ? @row['title'][-5,4] : nil

  nom = @row['title'].split(' ')
  nombre_cientifico = nil

  infraesp.each do |infra|
    if @row['title'].include?(infra)
      nombre_cientifico = "#{nom[0]} #{nom[1]} #{nom[2]} #{nom[3]}"  # infraespecie
      break
    else
      nombre_cientifico = "#{nom[0]} #{nom[1]}"  # especie
    end
  end

  nombre_cientifico = nombre_cientifico.gsub(',','').strip

  if nombre_cientifico[-1,1] == '.'  #Quitando el ultimo caracter que era un punto
    nombre_cientifico = nombre_cientifico[0..-2]
  end

  v = Validacion.new
  v.nombre_cientifico = nombre_cientifico
  v.encuentra_por_nombre
  validacion = v.validacion

  if validacion[:estatus] && validacion[:msg].include?('Búsqueda exacta')
    v.taxon_estatus

    if v.validacion[:estatus]
      v.validacion[:taxon] = v.validacion[:taxon_valido] if v.validacion[:taxon_valido].present?
      @bitacora.puts "#{@row['id']},#{@row['idcapa']},\"#{@row['title']}\",#{nombre_cientifico},#{v.validacion[:taxon].nombre_cientifico},\"#{v.validacion[:msg]}\",#{año}"
    else
      @bitacora.puts "#{@row['id']},#{@row['idcapa']},\"#{@row['title']}\",#{nombre_cientifico},,\"#{v.validacion[:msg]}\",#{año}"
    end

  elsif validacion[:estatus] && validacion[:msg].include?('Búsqueda similar')
    v.quita_subgeneros
    v.taxon_estatus

    if v.validacion[:estatus]
      v.validacion[:taxon] = v.validacion[:taxon_valido] if v.validacion[:taxon_valido].present?
      @bitacora.puts "#{@row['id']},#{@row['idcapa']},\"#{@row['title']}\",#{nombre_cientifico},#{v.validacion[:taxon].nombre_cientifico},\"#{v.validacion[:msg]}\",#{año}"
    else
      @bitacora.puts "#{@row['id']},#{@row['idcapa']},\"#{@row['title']}\",#{nombre_cientifico},,\"#{v.validacion[:msg]}\",#{año}"
    end

  elsif validacion[:taxones].present?
    v.quita_sinonimos_coincidencias
    v.quita_subgeneros
    v.taxon_estatus

    if v.validacion[:estatus]
      v.validacion[:taxon] = v.validacion[:taxon_valido] if v.validacion[:taxon_valido].present?
      @bitacora.puts "#{@row['id']},#{@row['idcapa']},\"#{@row['title']}\",#{nombre_cientifico},#{v.validacion[:taxon].nombre_cientifico},\"#{v.validacion[:msg]}\",#{año}"
    else
      @bitacora.puts "#{@row['id']},#{@row['idcapa']},\"#{@row['title']}\",#{nombre_cientifico},\"#{validacion[:taxones].map(&:nombre_cientifico).join(', ')}\",\"#{validacion[:msg]}\",#{año}"
    end

  else
    @bitacora.puts "#{@row['id']},#{@row['idcapa']},\"#{@row['title']}\",#{nombre_cientifico},,\"#{validacion[:msg]}\",#{año}"
  end

end

def lee_csv(csv_path)
  CSV.foreach(csv_path, :headers => true) do |r|
    @row = r
    #next unless @row["id"] == "7017"
    Rails.logger.debug "\tID: #{@row['id']}" if OPTS[:debug]
    actualiza_mapa_sig
  end

  @bitacora.close
end

def bitacora
  log_path = Rails.root.join('tools', 'mapas_SIG', Time.now.strftime('%Y-%m-%d_%H%M%S') + '_SIG.csv')
  @bitacora ||= File.new(log_path, 'a+')
  @bitacora.puts "id,idcapa,title,nombre científico,nombre científico validado,msg,año"
end


Rails.logger.debug "Iniciando el script ..." if OPTS[:debug]
start_time = Time.now

if ARGV.present? && ARGV.any? && ARGV.length == 1

  if File.exist?(ARGV[0])
    bitacora
    lee_csv(ARGV[0])
  else
    Rails.logger.debug "\tEl archivo: #{ARGV[0]}, no existe." if OPTS[:debug]
  end

end

Rails.logger.debug "Terminó en #{Time.now - start_time} seg" if OPTS[:debug]
