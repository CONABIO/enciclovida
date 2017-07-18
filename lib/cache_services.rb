module CacheServices
  def guarda_observaciones
    puts "\t\tIniciando el minado de las observaciones"

    # Solo actualizo las observaciones de naturalista ya que es un servicio costoso para pasarlo en kml y kmz
    if p = proveedor
      if p.naturalista_id.present?
        p.obs_naturalista
        p.kml_naturalista
        p.kmz_naturalista if p.naturalista_kml.present?
      end
    end

    # Falta el servicio de los registros del SNIB y del fuzzy match
    puts "\t\tTermino satisfactoriamente"
  end

  # Los servicios no se actualizaran en menos de un dia
  def escribe_cache(tiempo = 1.week)
    Rails.cache.write("cache_service_#{id}", true, :expires_in =>tiempo)
  end

  def existe_cache?
    Rails.cache.exist?("cache_service_#{id}")
  end

  def borra_cache
    Rails.cache.delete("cache_service_#{id}")
  end
end