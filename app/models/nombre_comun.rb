class NombreComun < ActiveRecord::Base

  self.table_name='nombres_comunes'
  has_many :nombres_regiones, :class_name => 'NombreRegion'
  has_many :especies, :through => :nombres_regiones, :class_name => 'Especie'

  def personalizaBusqueda
    "#{self.nombre_comun} (#{self.lengua})".html_safe
  end
end
