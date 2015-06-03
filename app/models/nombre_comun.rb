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
  scope :caso_rango_valores, ->(columna, rangos) { where("#{columna} IN (#{rangos})") }
  scope :especies_join, -> { joins('LEFT JOIN nombres_regiones ON nombres_regiones.nombre_comun_id=nombres_comunes.id').
      joins('LEFT JOIN especies ON especies.id=nombres_regiones.especie_id') }
  scope :categoria_taxonomica_join, -> { joins('LEFT JOIN categorias_taxonomicas ON categorias_taxonomicas.id=especies.categoria_taxonomica_id') }
  scope :adicional_join, -> { joins('LEFT JOIN adicionales ON adicionales.especie_id=especies.id') }
  scope :icono_join, -> { joins('LEFT JOIN iconos ON iconos.id=adicionales.icono_id') }

  # Select basico que contiene los campos a mostrar por ponNombreCientifico
  scope :select_basico, -> { select('especies.id, estatus, nombre_comun, nombre_cientifico, nombre_autoridad,
categoria_taxonomica_id, nombre_categoria_taxonomica,
adicionales.foto_principal, adicionales.nombre_comun_principal, iconos.taxon_icono, iconos.icono, iconos.nombre_icono, iconos.color_icono') }
    #categoria_taxonomica_id, nombre_categoria_taxonomica') }
  # select y joins basicos que contiene los campos a mostrar por ponNombreCientifico
  scope :datos_basicos, -> { select_basico.especies_join.categoria_taxonomica_join.adicional_join.icono_join }
  # Este select es para contar todas las especies partiendo del nombre comun
  scope :datos_count, -> { select('count(DISTINCT concat(especies.id, nombre_comun)) AS cuantos').especies_join }


  def species_or_lower?(cat, con_genero = false)
    if con_genero
      Especie::SPECIES_OR_LOWER.include?(cat) || Especie::BAJO_GENERO.include?(cat)
    else
      Especie::SPECIES_OR_LOWER.include?(cat)
    end
  end

  def completa_blurrily
    FUZZY_NOM_COM.put(nombre_comun, id)
  end

  def personalizaBusqueda
    "#{self.nombre_comun} (#{self.lengua})".html_safe
  end

  def exporta_redis(taxon)
    return unless ad = taxon.adicional
    return unless ic = ad.icono

    data = ''
    data << "{\"id\":#{id}#{taxon.id}000,"  #el ID de nombres_comunes no es unico (varios IDS repetidos)
    data << "\"term\":\"#{nombre_comun.limpia}\","
    data << "\"data\":{\"nombre_cientifico\":\"#{taxon.nombre_cientifico}\", "
    data << "\"nombre_icono\":\"#{ic.nombre_icono}\", \"icono\":\"#{ic.icono}\", \"color\":\"#{ic.color_icono}\", "
    data << "\"autoridad\":\"#{taxon.nombre_autoridad.limpia}\", \"id\":#{taxon.id}, \"estatus\":\"#{Especie::ESTATUS_VALOR[taxon.estatus]}\"}"
    data << "}\n"
  end
end
