module CacheServices
  # ***********************OJO, los metodos de este archivo cambiaron****************************
  # Actualiza los diferentes servicios a nivel taxon unos minutos despues que el usuario vio el taxon y
  # si es que caduco el cache
  def cache_services
    ns = naturalista_service
    #bi_service
    foto_principal_service
    nombre_comun_principal_service
    #snib_service  # De momento hasta que Everardo actualize su servicio

    if ns[:valido]
      naturalista_observaciones_service(ns[:proveedor])
    end

    puts "\t\tTermino satisfactoriamente"
  end

  # Despliega las fotos de referencia de naturalista, las guarda como json para no consultar siempre al vuelo.
  def fotos_naturalista_service
    if p = proveedor
      p.fotos_naturalista
    else
      p = Proveedor.crea_info_naturalista(self)
    end
  end

  def naturalista_service
    puts "\t\tGenerando la información de NaturaLista"

    if p = proveedor
      p.info_naturalista
    else
      p = Proveedor.crea_info_naturalista(self)
    end

    return {valido: false} unless p.instance_of?(Proveedor)
    return {valido: false} unless p.changed?
    return {valido: false} unless p.save

    puts "\t\tCambios en naturalista_info"

    # Para guardar las fotos nuevas de naturalista
    usuario = Usuario.find(CONFIG.usuario)
    p.fotos(usuario.id)
    puts "\t\tProceso fotos de NaturaLista"

    return {valido: true, proveedor: p}
  end

  # Se tuvo que separar, para correr las observaciones al final cuando ya se tiene la foto y los nombres comunes
  def naturalista_observaciones_service(proveedor)
    puts "\t\tGenerando las observaicones de NaturaLista"
    # Para las nuevas observaciones
    proveedor.kml_naturalista
    return unless proveedor.naturalista_kml.present?
    proveedor.kmz_naturalista
    puts "\t\tCon KMZ naturalista"
  end

  def snib_service
    puts "\t\tGenerando los registros del SNIB"
    if p = proveedor
      p.kml

      if p.snib_kml.present?
        if p.kmz
          puts "\t\tCon KMZ SNIB"
        end
      end
    end
  end

  def foto_principal_service
    puts "\t\tGenerando la foto principal"
    adicional = asigna_foto

    if adicional[:cambio]
      if adicional[:adicional].save
        puts "\t\tFoto principal cambio"
      end
    end
  end

  def nombre_comun_principal_service
    puts "\t\tGenerando el nombre común principal"
    adicional = asigna_nombre_comun

    if adicional[:cambio]
      if adicional[:adicional].save
        puts "\t\tNombre comun principal cambio"

        # Para crear el nombres comun y cientifico en redis (si hubo cambios)
        adicional[:adicional].actualiza_o_crea_nom_com_en_redis
        puts "\t\tNombres procesados en redis"

        # Para volver a poner los nombres comunes (catalogos) en el fuzzy match
        # puede que no hayan cambiado.
        blurrily_service
        puts "\t\tNombres procesados en blurrily"
      end
    end
  end

  # Servicios del fuzzy match
  def blurrily_service
    nombres_comunes.each do |nombre_comun|
      nombre_comun.completa_blurrily
    end
  end

  # Falta implementar el servicio del banco de imagenes
  def bi_service
  end

  # Los servicios no se actualizaran en menos de un dia
  def escribe_cache
    Rails.cache.write("cache_service_#{id}", true, :expires_in => 1.week)
  end

  def existe_cache?
    Rails.cache.exist?("cache_service_#{id}")
  end

  def borra_cache
    Rails.cache.delete("cache_service_#{id}")
  end
end