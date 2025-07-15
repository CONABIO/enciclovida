class Nombre < ActiveRecord::Base
  self.table_name = "#{CONFIG.bases.cat}.Nombre"
  self.primary_key = 'IdNombre'
  alias_attribute :estado_registro, :EstadoRegistro


end
