class Geoportal::SpSnib < GeoportalAbs

  self.table_name = 'sp_snib'
  self.primary_key = 'spid'

  has_many :ejemplares, class_name: 'Geoportal::Snib', foreign_key: :spid

  attr_accessor :resp

  def ejemplares_cat
    ejemplares.where("comentarioscatvalido LIKE '%Validado completamente con CAT.' AND idnombrecatvalido != '' AND idnombrecatvalido IS NOT NULL")
  end

  # Regresa el idnombrecatvalido de la la tabla snib y el número de registros
  def dame_id_cat_valido
    self.resp = { estatus: false, spid: spid }

    unless especievalidabusqueda.present?
      self.resp[:msg] = 'especievalidabusqueda esta vacio'
      return
    end

    registros = ejemplares_cat.map(&:idnombrecatvalido)
    nregistros = registros.length

    unless nregistros > 0
      self.resp[:msg] = 'No tenia registros en la tabla snib'
      return
    end

    id = registros.uniq
    if id.length == 1
      self.resp[:estatus] = true
      self.resp[:idnombrecatvalido] = id.first
      self.resp[:nregistros] = nregistros
    else
      self.resp[:msg] = 'Hubo más de un id que coincidio para la misma especie, no se añadio a la tabla'
    end

  end

  def guarda_id_cat_valido
    dame_id_cat_valido
    return unless resp[:estatus]

    self.idnombrecatvalido = resp[:idnombrecatvalido]
    self.nregistros = resp[:nregistros]

    unless save
      self.resp[:estatus] = false
      self.resp[:msg] = 'No pudo guardar el registro'
    end
  end

  # Asigna el idnombrecatvalido de la la tabla snib y el número de registros
  def self.guarda_id_a_todos
    Geoportal::SpSnib.all.each do |taxon|
      taxon.guarda_id_cat_valido
      Rails.logger.debug "[DEBUG] - #{taxon.resp.inspect}"
    end
  end

end
