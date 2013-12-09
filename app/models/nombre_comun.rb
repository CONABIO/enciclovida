class NombreComun < ActiveRecord::Base

  self.table_name='nombres_comunes'
  has_many :nombres_regiones

  def personalizaBusqueda
    "#{self.nombre_comun} (#{self.lengua})".html_safe
  end
end
