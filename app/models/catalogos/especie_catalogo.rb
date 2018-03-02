class EspecieCatalogo < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.RelNombreCatalogo'
  self.primary_keys= :IdNombre, :IdCatNombre

  # Los alias con las tablas de catalogos
  alias_attribute :especie_id, :IdNombre
  alias_attribute :catalogo_id, :IdCatNombre
  alias_attribute :descripcion, :Descripcion

  attr_accessor :catalogo_id_falso
  belongs_to :especie
  belongs_to :catalogo, :foreign_key => Catalogo.attribute_alias(:id)

  #validates_uniqueness_of :especie_id, :scope => :catalogo_id
end
