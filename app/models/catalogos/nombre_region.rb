class NombreRegion < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.RelNomNomComunRegion'
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

  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :foreign_key => 'especie_id'
  has_many :especies, :class_name => 'Especie', :foreign_key => 'id'    #para los asociados de las especies a traves del nombre_comun

end
