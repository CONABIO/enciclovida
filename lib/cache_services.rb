module CacheServices
  # REVISADO: Actualiza todos los servicios concernientes a un taxon, se empaqueto para que no estuviera en Especie
  def servicios
    suma_visita
    cuantas_especies_inferiores(estadistica_id: 2)  # Servicio para poner el numero totales de especies del taxon
    cuantas_especies_inferiores(estadistica_id: 3)  # Servicio para poner el numero totales de especies o inferiores del taxon
    cuantas_especies_inferiores({estadistica_id: 22, validas: true})  # Servicio para poner el numero totales de especies o inferiores del taxon
    cuantas_especies_inferiores({estadistica_id: 23, validas: true})  # Servicio para poner el numero totales de especies o inferiores del taxon
    guarda_observaciones_naturalista
    guarda_ejemplares_snib
  end

  # REVISADO: Guarda las observaciones desde la pagina de naturalista
  def guarda_observaciones_naturalista
    if !@especie.existe_cache?('observaciones_naturalista')
      @especie.delay(queue: 'observaciones_naturalista').guarda_observaciones_naturalista
    end
  end

  # REVISADO: Guarda los ejemplares del SNIB
  def guarda_ejemplares_snib
    if !@especie.existe_cache?('ejemplares_snib')
      @especie.delay(queue: 'ejemplares_snib').guarda_ejemplares_snib
    end
  end

  # REVISAO: Guarda los datos más importantes en el redis
  def guarda_redis
    @especie.delay(queue: 'redis').guarda_redis
  end

  # REVISADO: Suma una visita a la estadisticas
  def suma_visita
    if Rails.env.production?
      @especie.delay(queue: 'estadisticas').suma_visita
    else
      @especie.suma_visita
    end
  end

  # REVISADO: Cuenta en numero de especies o el numero de especies mas las inferiores de una taxon, depende del argumento
  def cuantas_especies_inferiores(opc = {})
    if params[:action] == 'show'
      if Rails.env.production?
        if !@especie.existe_cache?("estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]}")
          @especie.delay(queue: 'estadisticas').cuantas_especies_inferiores(opc)
        end
      else
        @especie.cuantas_especies_inferiores(opc)
      end
    end  # if show
  end

  def guarda_observaciones_naturalista
    if p = proveedor
      p.guarda_observaciones_naturalista
    else
      # Pone el cache para no volverlo a consultar, en caso que no tenga proveedor
      escribe_cache('observaciones_naturalista', eval(CONFIG.cache.observaciones_naturalista)) if Rails.env.production?
    end
  end

  def guarda_ejemplares_snib
    if p = proveedor
      p.guarda_ejemplares_snib
    else
      # Pone el cache para no volverlo a consultar, en caso que no tenga proveedor
      escribe_cache('ejemplares_snib', eval(CONFIG.cache.ejemplares_snib)) if Rails.env.production?
    end
  end

  # Los servicios no se actualizaran en menos de un dia
  def escribe_cache(recurso, tiempo = 1.day)
    Rails.cache.write("#{recurso}_#{id}", true, :expires_in =>tiempo)
  end

  def existe_cache?(recurso)
    Rails.cache.exist?("#{recurso}_#{id}")
  end

  def borra_cache(recurso)
    Rails.cache.delete("#{recurso}_#{id}")
  end
end