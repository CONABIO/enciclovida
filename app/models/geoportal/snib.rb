class Geoportal::Snib < GeoportalAbs

  self.table_name = 'snib'
  self.primary_key = 'idejemplar'

  attr_accessor :region_id, :tipo_region, :resp

  def dame_especies_por_region
    return {} unless (tipo_region.present? && region_id.present?)

    self.resp = Rails.cache.fetch("br_#{tipo_region}_#{region_id}", expires_in: eval(CONFIG.cache.busquedas_region)) do
      consulta_especies_por_region
    end
  end
  

  private

  def consulta_especies_por_region
    resp = Geoportal::Snib.select('idnombrecatvalido, COUNT(*) AS nregistros').where("#{tipo_region}='#{region_id}' AND idnombrecatvalido <> '' AND especievalidabusqueda <> '' AND comentarioscatvalido LIKE 'Validado completamente con CAT.%'").group(:idnombrecatvalido).order('nregistros DESC')

    resp.map{ |r| {r.idnombrecatvalido => r.nregistros} }.reduce({}, :merge)
  end  

end
