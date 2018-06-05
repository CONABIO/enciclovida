module CacheServices
  def guarda_observaciones_naturalista
    if p = proveedor
      p.guarda_observaciones_naturalista
    else
      # Pone el cache para no volverlo a consultar, en caso que no tenga proveedor
      escribe_cache('observaciones_naturalista', CONFIG.cache.observaciones_naturalista) if Rails.env.production?
    end
  end

  def guarda_ejemplares_snib
    if p = proveedor
      p.guarda_ejemplares_snib
    else
      # Pone el cache para no volverlo a consultar, en caso que no tenga proveedor
      escribe_cache('ejemplares_snib', CONFIG.cache.ejemplares_snib) if Rails.env.production?
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