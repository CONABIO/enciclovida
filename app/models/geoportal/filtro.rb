class Geoportal::Filtro < GeoportalAbs

  attr_accessor :taxon

  def dame_taxon
    scat = Scat.where(catalogo_id: idnombrecatvalido)
    return unless scat.length == 1

    if t = scat.first.especie
      self.taxon = t.dame_taxon_valido
    end
  end

  def completa_filtros
    dame_taxon
    return unless taxon

    # nom, iucn y cites
    ids_nom = [14, 15, 16, 17]
    ids_iucn = [25, 26, 27, 28, 29, 31, 21]
    ids_cites = [22, 23, 24]
    catalogos = taxon.catalogos.map(&:id)

    nom = ids_nom & catalogos
    self.nom = nom.first if nom.any?

    iucn = ids_iucn & catalogos
    self.iucn = iucn.first if iucn.any?

    cites = ids_cites & catalogos
    self.cites = cites.first if cites.any?

    # tipo de distribucion
    tipo_distribucion = taxon.tipos_distribuciones.map(&:id)

    if tipo_distribucion.any?
      self.endemica = true if tipo_distribucion.include?(3)
      self.nativa = true if tipo_distribucion.include?(7)
      self.exotica = true if tipo_distribucion.include?(10)
      self.exoticainvasora = true if tipo_distribucion.include?(6)
    end

    save if changed?
  end

  def self.completa_todos
    Geoportal::Filtro.all.each do |f|
      f.completa_filtros
    end
  end

end