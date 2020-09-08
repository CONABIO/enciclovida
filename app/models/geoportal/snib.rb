class Geoportal::Snib < GeoportalAbs

  self.table_name = 'snib'
  self.primary_key = 'idejemplar'

  attr_accessor :region_id, :tipo_region, :campo_tipo_region, :resp

  def especies_por_region
    if tipo_region.present? && region_id.present?
      tipo_region_a_llave_foranea

      unless (campo_tipo_region.present? && region_id.present?)
        self.resp = { estatus: false, msg: 'Revisar tipo_region y/o region_id' }  
        return
      end
    end

    self.resp = Rails.cache.fetch("br_#{tipo_region}_#{region_id}", expires_in: eval(CONFIG.cache.busquedas_region)) do
      consulta_especies_por_region
    end
  end
  

  private

  def consulta_especies_por_region
    resp = Geoportal::Snib.select('idnombrecatvalido, COUNT(*) AS nregistros').where("idnombrecatvalido <> '' AND especievalidabusqueda <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%'").group(:idnombrecatvalido).order('nregistros DESC')
    resp = resp.where("#{campo_tipo_region}=#{region_id}") if campo_tipo_region.present?

    if resp.any?
      { estatus: true, resultados: resp.map{ |r| {r.idnombrecatvalido => r.nregistros} }.reduce({}, :merge) }
    else
      { estatus: false, msg: 'Sin resultados en esta región' }
    end
  end  

  # Regresa la llave foranea dependiendo el tipo de region
  def tipo_region_a_llave_foranea
    case tipo_region
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
