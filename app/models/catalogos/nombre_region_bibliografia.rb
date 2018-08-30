class NombreRegionBibliografia < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.RelNomNomComunRegionBiblio"
  self.primary_keys = :IdNombreComun, :IdNombre, :IdRegion, :IdBibiografia

  attr_accessor :bibliografia_id_falsa
  belongs_to :especie
  belongs_to :region
  belongs_to :bibliografia, :foreign_key => Bibliografia.attribute_alias(:id)
  belongs_to :nombre_comun

end
