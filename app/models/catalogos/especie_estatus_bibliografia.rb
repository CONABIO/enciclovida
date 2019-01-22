class EspecieEstatusBibliografia < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.RelacionBibliografia"
  self.primary_keys= :IdNombre, :IdNombreRel, :IdTipoRelacion, :IdBibliografia

  # Los alias con las tablas de catalogos
  alias_attribute :especie_id1, :IdNombre
  alias_attribute :especie_id2, :IdNombreRel
  alias_attribute :estatus_id, :IdTipoRelacion
  alias_attribute :bibliografia_id, :IdBibliografia
  alias_attribute :observaciones, :Observaciones

  belongs_to :especie, :foreign_key => attribute_alias(:especie_id1)
  belongs_to :especie, :foreign_key => attribute_alias(:especie_id2)
  belongs_to :estatus, :foreign_key => attribute_alias(:estatus_id)
  belongs_to :bibliografia, :foreign_key => attribute_alias(:bibliografia_id)

end
