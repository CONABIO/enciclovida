class NombreComun < ActiveRecord::Base

  self.table_name='nombres_comunes'
  self.primary_key = 'id'


  has_many :nombres_regiones, :class_name => 'NombreRegion'
  has_many :especies, :through => :nombres_regiones, :class_name => 'Especie'

  scope :caso_insensitivo, ->(columna, valor) { where("LOWER(#{columna}) LIKE LOWER('%#{valor}%')") }
  scope :caso_empieza_con, ->(columna, valor) { where("#{columna} LIKE '#{valor}%'") }
  scope :caso_sensitivo, ->(columna, valor) { where("#{columna}='#{valor}'") }
  scope :caso_termina_con, ->(columna, valor) { where("#{columna} LIKE '%#{valor}'") }
  scope :caso_fecha, ->(columna, valor) { where("CAST(#{columna} AS TEXT) LIKE '%#{valor}%'") }
  scope :especies_join, -> { joins('LEFT JOIN nombres_regiones ON nombres_regiones.nombre_comun_id=nombres_comunes.id').
      joins('LEFT JOIN especies ON especies.id=nombres_regiones.especie_id') }
  scope :categoria_taxonomica_join, -> { joins('LEFT JOIN categorias_taxonomicas ON categorias_taxonomicas.id=especies.categoria_taxonomica_id') }
  scope :nom_com, -> { especies_join.categoria_taxonomica_join }

  def species_or_lower?(cat)
    Especie::SPECIES_OR_LOWER.include? cat
  end

  def completa_blurrily
    FUZZY_NOM_CIEN.put(nombre_comun, id)
  end

  def personalizaBusqueda
    "#{self.nombre_comun} (#{self.lengua})".html_safe
  end

  def exporta_redis(taxon)
    foto = taxon.foto_principal.present? ? "<img src='#{taxon.foto_principal}' alt='#{taxon.nombre_cientifico}' style='width:45px;height:45px;' class='img-thumbnail' \>" :
        "<img src='/assets/app/iconic_taxa/mammalia-75px.png' alt='#{taxon.nombre_cientifico}' style='width:45px;height:45px;' class='img-thumbnail' \>"

    data = ''
    data << "{\"id\":#{id}#{0},"  #el ID de nombres_comunes no es unico (varias IDS repetidos)
    data << "\"term\":\"#{Limpia.cadena(nombre_comun.humanizar)}\","
    data <<  "\"score\":2,"
    data << "\"data\":{\"nombre_cientifico\":\"#{Limpia.cadena(taxon.nombre_cientifico)}\", "
    data <<  "\"foto\":\"#{Limpia.cadena(foto)}\", \"autoridad\":\"#{Limpia.cadena(taxon.nombre_autoridad)}\", \"id\":#{taxon.id}, \"estatus\":#{taxon.estatus}}"
    data << "}\n"
  end
end
