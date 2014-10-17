class NombreComunBio < ActiveRecord::Base

  self.table_name='NomComun'
  self.primary_key='IdNomComun'

  alias_attribute :id, :IdNomComun
  alias_attribute :lengua, :Lengua
  alias_attribute :nombre_comun, :NomComun

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


  def personalizaBusqueda
    "#{self.nombre_comun} (#{self.lengua})".html_safe
  end
end
