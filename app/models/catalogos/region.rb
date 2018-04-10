class Region < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.Region'
  self.primary_key = 'IdRegion'

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdRegion
  alias_attribute :nombre_region, :NombreRegion
  alias_attribute :tipo_region_id, :IdTipoRegion
  alias_attribute :clave_region, :ClaveRegion
  alias_attribute :id_region_asc, :IdReionAsc

  belongs_to :tipo_region

end
