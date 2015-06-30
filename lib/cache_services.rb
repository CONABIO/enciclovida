module CacheServices
  # Actualiza los diferentes servicios a nivel taxon unos minutos despues que el usuario vio el taxon y
  # si es que caduco el cache
  def cache_services
    ns = naturalista_service
    #bi_service
    foto_principal_service
    nombre_comun_principal_service
    snib_service

    if ns[:valido]
      naturalista_observaciones_service(ns[:proveedor])
    end

    puts "\t\tTermino satisfactoriamente"
  end

  def naturalista_service
    if proveedor = @especie.proveedor
      proveedor.info_naturalista
    else
      proveedor = Proveedor.crea_info_naturalista(@especie)
    end

    return {valido: false} unless proveedor.instance_of?(Proveedor)
    return {valido: false} unless proveedor.changed?
    return {valido: false} unless proveedor.save

    puts "\t\tCambios en naturalista_info"

    # Para guardar las fotos nuevas de naturalista
    usuario = Usuario.where(usuario: CONFIG.usuario).first
    proveedor.fotos(usuario.id)
    puts "\t\tProceso fotos de NaturaLista"

    return {valido: true, proveedor: proveedor}
  end

  # Se tuvo que separar, para correr las observaciones al final cuando ya se tiene la foto y los nombres comunes
  def naturalista_observaciones_service(proveedor)
    # Para las nuevas observaciones
    proveedor.kml_naturalista
    return unless proveedor.naturalista_kml.present?
    proveedor.kmz_naturalista
    puts "\t\tCon KMZ naturalista"
  end

  def snib_service
    if proveedor = @especie.proveedor
      proveedor.kml

      if proveedor.snib_kml.present?
        if proveedor.kmz
          puts "\t\tCon KMZ SNIB"
        end
      end
    end
  end

  def foto_principal_service
    adicional = @especie.asigna_foto

    if adicional[:cambio]
      if adicional[:adicional].save
        puts "\t\tFoto principal cambio"
      end
    end
  end

  def nombre_comun_principal_service
    adicional = @especie.asigna_nombre_comun

    if adicional[:cambio]
      if adicional[:adicional].save
        puts "\t\tNombre comun principal cambio"

        # Para crear el nombres comun y cientifico en redis (si hubo cambios)
        adicional[:adicional].actualiza_o_crea_nom_com_en_redis
        puts "\t\tNombres procesados en redis"

        # Para volver a poner los nombres comunes (catalogos) en el fuzzy match
        # puede que no hayan cambiado.
        blurrily_service(adicional[:adicional])
        puts "\t\tNombres procesados en blurrily"
      end
    end
  end

  # Servicios del fuzzy match
  def blurrily_service(adicional)
    adicional.especie.nombres_comunes.each do |nombre_comun|
      nombre_comun.completa_blurrily
    end
  end

  # Falta implementar el servicio del banco de imagenes
  def bi_service
    CONFIG.site_url
  end
end