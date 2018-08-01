class EspecieRegion < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.RelNombreRegion'
  self.primary_keys= :IdNombre, :IdRegion

  # Los alias con las tablas de catalogos
  alias_attribute :especie_id, :IdNombre
  alias_attribute :region_id, :IdRegion
  alias_attribute :observaciones, :Observaciones

  attr_accessor :region_id_falso
  validates_presence_of :especie_id, :region_id

  belongs_to :region, :foreign_key => Region.attribute_alias(:id)
  belongs_to :especie
  belongs_to :tipo_distribucion, :foreign_key => TipoDistribucion.attribute_alias(:id)
  has_many :nombres_regiones, :class_name => 'NombreRegion', :foreign_key => 'especie_id', :dependent => :destroy

end
