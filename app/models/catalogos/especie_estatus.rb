class EspecieEstatus < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.Nombre_Relacion'
  self.primary_keys= :IdNombre, :IdNombreRel, :IdTipoRelacion

  # Los alias con las tablas de catalogos
  alias_attribute :especie_id1, :IdNombre
  alias_attribute :especie_id2, :IdNombreRel
  alias_attribute :estatus_id, :IdTipoRelacion

  belongs_to :especie, :foreign_key => :especie_id1
  belongs_to :especie, :foreign_key => :especie_id2
  belongs_to :estatus, :foreign_key => attribute_alias(:estatus_id)

  scope :sinonimos, -> { where(estatus_id: 1) }
  scope :homonimos, -> { where(estatus_id: 8) }

end
