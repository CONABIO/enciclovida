class Api::Iucn < Api::Descripcion

  def initialize(opc={})
    super(opc)
    self.servidor = servidor || CONFIG.site_url
  end

  def nombre
    'IUCN Red List'
  end

  def dame_descripcion
    iucn = IUCNService.new
    iucn.taxon = Especie.find(taxon.id)
    iucn.encuentra_descripcion
    return nil unless iucn.datos[:estatus]

    solicita("especies/#{taxon.id}/descripcion-iucn")
  end

end