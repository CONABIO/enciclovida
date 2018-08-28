# Esta biblioteca emula la gema ancestry, fue necesaria por que el campo cambio y es muy especifico
module AncestryPersonalizado

  # REVISADO: Para ver si un taxon es root
  def is_root?
    return false unless ancestry_ascendente_directo.present?
    ancestros = ancestry_ascendente_directo.split(',').map{|a| a if a.present?}.compact
    return false unless ancestros.any?

    ancestros.count == 1 ? true : false
  end

  # REVISADO: Devuelve el taxon root con active record
  def root
    if is_root?
      self
    else
      return Especie.none unless ancestry_ascendente_directo.present?
      ancestros = ancestry_ascendente_directo.split(',').map{|a| a.to_i if a.present?}.compact
      return Especie.none unless ancestros.any?

      Especie.find(ancestros.first)
    end
  end

  # REVISADO: Regresa el id root
  def root_id
    if is_root?
      id
    else
      root.id
    end
  end

  # REVISADO: Devuelve un array de los ancestros y el taxon en cuestion
  def path_ids
    ancestry_ascendente_directo.split(',').map{|a| a.to_i if a.present?}.compact
  end

  # REVISADO: Devuelve el active record de los ancestros y el taxon en cuestion
  def path
    Especie.where(id: path_ids)
  end

  # REVISADO: Devuelve los descendentes en un array
  def descendant_ids
    descendants.map(&:id)
  end

  # REVISADO: Devuelve los descendentes como active record
  def descendants
    Especie.where("#{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%,?,%'", id).where.not(id: id)
  end

  def ancestor_ids
    path_ids - [id]
  end

  def ancestors
    Especie.where(id: ancestor_ids)
  end
end
