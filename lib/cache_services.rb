module CacheServices
  # Actualiza los diferentes servicios a nivel taxon unos minutos despues que el usuario vio el taxon y
  # si es que caduco el cache
  def services
    naturalista_service
    snib_service
    foto_principal_service
    nombre_comun_principal_service
  end

  def naturalista_service
    if proveedor = @especie.proveedor
      proveedor.info_naturalista
    else
      proveedor = Proveedor.crea_info_naturalista(@especie)
    end

    return unless proveedor.instance_of?(Proveedor)
    return unless proveedor.changed?
    return unless proveedor.save

    # Para guardar las fotos nuevas de naturalista
    usuario = Usuario.where(usuario: CONFIG.usuario).first
    proveedor.fotos(usuario.id)

    # Para las nuevas observaciones
    proveedor.kml_naturalista
    return unless proveedor.naturalista_kml.present?
    proveedor.kmz_naturalista
  end

  def snib_service
    if proveedor = @especie.proveedor
      proveedor.kml

      if proveedor.snib_kml.present?
        if proveedor.kmz
          puts "\t\tCon KMZ" if OPTS[:debug]
        end
      end
    end
  end

  def foto_principal_service
    adicional = @especie.asigna_foto

    if adicional[:cambio]
      if adicional[:adicional].save
        puts "\t\tFoto principal cambio" if OPTS[:debug]
      end
    end
  end

  def nombre_comun_principal_service
    adicional = @especie.asigna_nombre_comun

    if adicional[:cambio]
      if adicional[:adicional].save
        puts "\t\tNombre comun principal cambio" if OPTS[:debug]

        # Para crear el nombres comun y cientifico en redis si hubo cambios
        adicional[:adicional].actualiza_o_crea_nom_com_en_redis
      end
    end
  end

  # Falta implementar el servicio del banco de imagenes
  def bi_service
    'HOLAAAA!!!'
  end
end