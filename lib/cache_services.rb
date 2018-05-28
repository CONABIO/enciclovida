module CacheServices
  # REVISADO: Actualiza todos los servicios concernientes a un taxon, se empaqueto para que no estuviera en Especie
  def servicios
    #suma_visita_servicio
    #cuantas_especies_inferiores_servicio(estadistica_id: 2)  # Servicio para poner el numero totales de especies del taxon
    #cuantas_especies_inferiores_servicio(estadistica_id: 3)  # Servicio para poner el numero totales de especies o inferiores del taxon
    #cuantas_especies_inferiores_servicio({estadistica_id: 22, validas: true})  # Servicio para poner el numero totales de especies o inferiores del taxon
    #cuantas_especies_inferiores_servicio({estadistica_id: 23, validas: true})  # Servicio para poner el numero totales de especies o inferiores del taxon
    #guarda_observaciones_naturalista_servicio
    #guarda_ejemplares_snib_servicio
    guarda_redis_servicio
    guarda_pez_servicios
  end

  # REVISAO: Guarda los datos más importantes en el redis
  def guarda_redis_servicio
    if Rails.env.production?
      delay(queue: 'redis').guarda_redis
    else
      guarda_redis
    end
  end

  # REVISADO: Guarda la información asociada al pez
  def guarda_pez_servicios
    if Rails.env.production?
      pez.delay(queue: 'peces').save if pez
    else
      pez.save if pez
    end
  end

  # REVISADO: Suma una visita a la estadisticas
  def suma_visita_servicio
    if Rails.env.production?
      delay(queue: 'estadisticas').suma_visita
    else
      suma_visita
    end
  end

  # REVISADO: Cuenta en numero de especies o el numero de especies mas las inferiores de una taxon, depende del argumento
  def cuantas_especies_inferiores_servicio(opc = {})
    if !existe_cache?("estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]}")
      if Rails.env.production?
        delay(queue: 'estadisticas').cuantas_especies_inferiores(opc)
      else
        cuantas_especies_inferiores(opc)
      end

      escribe_cache("estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]}", eval(CONFIG.cache.cuantas_especies_inferiores)) if Rails.env.production?
    end
  end

  # REVISADO: Guarda las observaciones desde la pagina de naturalista
  def guarda_observaciones_naturalista_servicio
    if !existe_cache?('observaciones_naturalista')
      if p = proveedor
        if Rails.env.production?
          p.delay(queue: 'observaciones_naturalista').guarda_observaciones_naturalista
        else
          p.guarda_observaciones_naturalista
        end
      end

      escribe_cache('observaciones_naturalista', eval(CONFIG.cache.observaciones_naturalista)) if Rails.env.production?
    end
  end

  # REVISADO: Guarda los ejemplares del SNIB
  def guarda_ejemplares_snib_servicio
    if !existe_cache?('observaciones_naturalista')
      if p = proveedor
        if Rails.env.production?
          p.delay(queue: 'observaciones_naturalista').guarda_ejemplares_snib
        else
          p.guarda_ejemplares_snib
        end
      end

      escribe_cache('ejemplares_snib', eval(CONFIG.cache.ejemplares_snib)) if Rails.env.production?
    end
  end

  # REVISADO: Escribe un cache
  def escribe_cache(recurso, tiempo = 1.day)
    Rails.cache.write("#{recurso}_#{id}", true, :expires_in => tiempo)
  end

  # REVISADO: Verifica que el cache exista
  def existe_cache?(recurso)
    Rails.cache.exist?("#{recurso}_#{id}")
  end

  # REVISADO: Borra un cache
  def borra_cache(recurso)
    Rails.cache.delete("#{recurso}_#{id}")
  end
end