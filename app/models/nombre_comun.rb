class NombreComun < ActiveRecord::Base

  self.table_name='nombres_comunes'
  has_many :nombres_regiones

end
