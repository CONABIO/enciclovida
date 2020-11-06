class Geoportal::Snib < GeoportalAbs

  self.table_name = 'snib'

  attr_accessor :resp, :params, :campo_tipo_region

  # Regresa todas las especies que coincidan con el tipo de region y id seleccionado
  def especies
    tipo_region_a_llave_foranea
    unless campo_tipo_region.present?
      self.resp = { estatus: false, msg: 'Revisar tipo_region' }  
      return
    end

    self.resp = Rails.cache.fetch("br_#{params[:tipo_region]}_#{params[:region_id]}", expires_in: eval(CONFIG.cache.busquedas_region)) do
      consulta_especies_por_region
    end
  end

  # Borra el cache de las especies por region
  def borra_cache_especies
    Rails.cache.delete("br_#{params[:tipo_region]}_#{params[:region_id]}") if Rails.cache.exist?("br_#{params[:tipo_region]}_#{params[:region_id]}")
  end

  # Regresa todos los ejemplares que coincidan con el tipo de region,region id y idcat
  def ejemplares
    tipo_region_a_llave_foranea
    unless campo_tipo_region.present?
      self.resp = { estatus: false, msg: 'Revisar tipo_region' }  
      return
    end
    
    # Hace el query en vivo, ya que es una cantidad relativamente pequeña de ejemplares
    if campo_tipo_region.present? && params[:region_id].present? 
      self.resp = consulta_ejemplares_por_region
    else  # Lo guarda en cache
      self.resp = Rails.cache.fetch("br_#{params[:especie_id]}_#{params[:tipo_region]}_#{params[:region_id]}", expires_in: eval(CONFIG.cache.busquedas_region)) do
        consulta_ejemplares_por_region
      end
    end
  end
  

  private

  def consulta_especies_por_region
    resultados = Geoportal::Snib.select('idnombrecatvalido, COUNT(*) AS nregistros').where("idnombrecatvalido <> '' AND especievalidabusqueda <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%'").group(:idnombrecatvalido).order('nregistros DESC')
    
    if campo_tipo_region.present? && params[:region_id].present?
      resultados = resultados.where("#{campo_tipo_region}=#{params[:region_id]}")
    elsif campo_tipo_region.present?  # Cuando es el conteo general por alguna division politica
      resultados = resultados.where("#{campo_tipo_region} IS NOT NULL") 
    end

    if resultados.length > 0
      { estatus: true, resultados: resultados.map{ |r| {r.idnombrecatvalido => r.nregistros} }.reduce({}, :merge) }
    else
      { estatus: false, msg: 'Sin resultados en esta región' }
    end
  end  

  # Regresa todos los ejemplares de la especie seleccionada, de una forma simplificada
  def consulta_ejemplares_por_region
    resultados = Geoportal::Snib.select(:id, :latitud, :longitud, :tipocoleccion).where(idnombrecatvalido: params[:especie_id])

    if campo_tipo_region.present? && params[:region_id].present?
      resultados = resultados.where("#{campo_tipo_region}=#{params[:region_id]}")
    elsif campo_tipo_region.present?  # Cuando son los registros de alguna division politica en particular
      resultados = resultados.where("#{campo_tipo_region} IS NOT NULL") 
    end

    return { estatus: false, msg: 'Sin resultados' } unless resultados.any?
    ejemplares = {}

    resultados.each do |r|
      ejemplares[r.tipocoleccion] = [] unless ejemplares[r.tipocoleccion].present?
      ejemplares[r.tipocoleccion] << [r.longitud, r.latitud, r.id]
    end
    
    { estatus: true, resultados: ejemplares } 
  end
  
  # Regresa la llave foranea dependiendo el tipo de region
  def tipo_region_a_llave_foranea
    case params[:tipo_region]
    when 'estado'
      self.campo_tipo_region = 'entid'
    when 'municipio'
      self.campo_tipo_region = 'munid'
    when 'anp'
      self.campo_tipo_region = 'anpid'
    when 'ecorregion'
      self.campo_tipo_region = 'ecorid'
    else  
      self.campo_tipo_region = nil
    end 
  end

end
