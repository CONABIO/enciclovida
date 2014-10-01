class NombreRegionBio < ActiveRecord::Base

  self.table_name='RelNomNomComunRegion'
  self.primary_keys= :IdNombre, :IdRegion, :IdNomComun

  alias_attribute :especie_id, :IdNombre
  alias_attribute :region_id, :IdRegion
  alias_attribute :nombre_comun_id, :IdNomComun

  attr_accessor :nombre_comun_id_falso
  belongs_to :region, :class_name => 'RegionBio', :foreign_key => 'IdRegion'
  belongs_to :especie, :class_name => 'EspecieBio', :foreign_key => 'IdNombre'
  belongs_to :nombre_comun, :class_name => 'NombreComunBio', :foreign_key => 'IdNomComun'
  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :foreign_key => 'especie_id'
  has_many :especies, :class_name => 'Especie', :foreign_key => 'id'    #para los asociados de las especies a traves del nombre_comun

end
