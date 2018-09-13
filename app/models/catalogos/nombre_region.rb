class NombreRegion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.RelNomNomComunRegion"
  self.primary_keys = :IdNomComun, :IdNombre, :IdRegion

  # Los alias con las tablas de catalogos
  alias_attribute :nombre_comun_id, :IdNomComun
  alias_attribute :especie_id, :IdNombre
  alias_attribute :region_id, :IdRegion
  alias_attribute :observaciones, :Observaciones

  attr_accessor :nombre_comun_id_falso
  belongs_to :region
  belongs_to :especie
  belongs_to :nombre_comun, :foreign_key => NombreComun.attribute_alias(:id)
  belongs_to :bibliografia, :foreign_key => NombreComun.attribute_alias(:id)

end
