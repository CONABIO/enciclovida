OPTS = Trollop::options do
  banner <<-EOS

*** Guarda en cache los distintos tipos de regiones

Usage:

  rails r tools/regiones_mapas/crea_cache_regiones.rb -d

where [options] are:
  EOS
  opt :debug, 'Print debug statements', :type => :boolean, :short => '-d'
end

def especies_por_grupo_estados
  grupos = %w(Mamíferos Aves Reptiles Anfibios Peces Invertebrados Plantas Hongos Bacterias Protoctistas)

  # estados
  Estado.select(:entid, :nom_ent).each do |estado|
  #Estado.select(:entid, :nom_ent).where(entid: 1).each do |estado|
    grupos.each do |grupo|
      params = { tipo_region: 'estado', grupo: grupo, estado_id: estado.entid }
      Rails.logger.debug "Opcion: #{params}" if OPTS[:debug]

      begin
        br = BusquedaRegion.new
        br.params = params
        br.especies_por_grupo
        Rails.logger.debug "\tLo guardo bien" if OPTS[:debug]
      rescue
        Rails.logger.debug "\tOcurrio un error" if OPTS[:debug]
      end

    end  # end grupos

    especies_por_grupo_municipios({ estado_id: estado.entid, tipo_region: 'municipio', nom_ent: estado.nom_ent })
  end  # end estados

end

def especies_por_grupo_municipios(params)
  grupos = %w(Mamíferos Aves Reptiles Anfibios Peces Invertebrados Plantas Hongos Bacterias Protoctistas)

  Municipio.select(:munid,:nom_mun).where(nom_ent: params[:nom_ent]).each do |municipio|
    conteo_por_municipio(params.merge({ municipio_id: municipio.munid }))

    grupos.each do |grupo|
      params.merge!({ municipio_id: municipio.munid, grupo: grupo })
      Rails.logger.debug "\t\t\tOpcion: #{params}" if OPTS[:debug]

      begin
        br = BusquedaRegion.new
        br.params = params
        br.especies_por_grupo
        Rails.logger.debug "\t\t\t\tLo guardo bien" if OPTS[:debug]
      rescue
        Rails.logger.debug "\t\t\t\tOcurrio un error" if OPTS[:debug]
      end

    end  # end grupos
  end  # end municipios

end

def conteo_por_municipio(params)
  Rails.logger.debug "\t\tOpcion: #{params}" if OPTS[:debug]

  begin
    br = BusquedaRegion.new
    br.params = params
    br.cache_conteo_por_grupo
    Rails.logger.debug "\t\t\tLo guardo bien" if OPTS[:debug]
  rescue
    Rails.logger.debug "\t\t\tOcurrio un error" if OPTS[:debug]
  end
end

def actualiza_ejemplares_snib
  Proveedor.all.each do |proveedor|
    Rails.logger.debug "\tGuardando ejemplares con: #{proveedor.especie_id}" if OPTS[:debug]

    begin
      proveedor.guarda_ejemplares_snib
      Rails.logger.debug "\t\tLo guardo bien" if OPTS[:debug]
    rescue
      Rails.logger.debug "\t\tOcurrio un error" if OPTS[:debug]
    end

  end
end

start_time = Time.now

especies_por_grupo_estados
actualiza_ejemplares_snib

Rails.logger.debug "Termino en #{Time.now - start_time} seg" if OPTS[:debug]