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
  scope :caso_nombre_comun_y_cientifico, ->(nombre) { where("LOWER(nombre_comun) LIKE LOWER('%#{nombre}%') OR LOWER(nombre_cientifico) LIKE LOWER('%#{nombre}%')") }
  scope :especies_join, ->(join_type='LEFT') { joins("#{join_type} JOIN nombres_regiones ON nombres_regiones.nombre_comun_id=nombres_comunes.id").
      joins("#{join_type} JOIN especies ON especies.id=nombres_regiones.especie_id") }
  scope :categoria_taxonomica_join, ->(join_type='LEFT') { joins("#{join_type} JOIN categorias_taxonomicas ON categorias_taxonomicas.id=especies.categoria_taxonomica_id") }
  scope :adicional_join, ->(join_type='LEFT') { joins("#{join_type} JOIN adicionales ON adicionales.especie_id=especies.id") }
  scope :icono_join, -> { joins('LEFT JOIN iconos ON iconos.id=adicionales.icono_id') }

  # Select basico que contiene los campos a mostrar por ponNombreCientifico
  scope :select_basico, ->(adicionales=[]) { select('DISTINCT especies.id, estatus, nombre_cientifico, nombre_autoridad, categoria_taxonomica_id, nombre_categoria_taxonomica,
adicionales.foto_principal, adicionales.fotos_principales, adicionales.nombre_comun_principal' +
                                                        (adicionales.any? ? ',' + adicionales.join(',') : '')) }
    #categoria_taxonomica_id, nombre_categoria_taxonomica') }
  # select y joins basicos que contiene los campos a mostrar por ponNombreCientifico
  scope :datos_basicos, ->(adicionales=[], join_type='LEFT') { select_basico(adicionales).especies_join(join_type).categoria_taxonomica_join(join_type).adicional_join(join_type) }
  # Este select es para contar todas las especies partiendo del nombre comun
  scope :datos_count, ->(join_type='LEFT') { select('count(DISTINCT especies.id) AS cuantos').especies_join(join_type) }

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
end