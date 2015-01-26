class EstatusBio < ActiveRecord::Base
  self.table_name='Tipo_Relacion'
  self.primary_key='IdTipoRelacion'

  has_many :especie_estatuses
end
