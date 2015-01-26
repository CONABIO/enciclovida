class EspecieEstatusBio < ActiveRecord::Base
  self.table_name='Nombre_Relacion'
  self.primary_keys= :IdNombre, :IdNombreRel, :IdTipoRelacion

  belongs_to :especie, :foreign_key => :especie_id1
  belongs_to :especie, :foreign_key => :especie_id2
  belongs_to :estatus
end
