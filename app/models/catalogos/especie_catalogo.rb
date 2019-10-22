class EspecieCatalogo < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.RelNombreCatalogo"
  self.primary_keys = :IdNombre, :IdCatNombre

  # Los alias con las tablas de catalogos
  alias_attribute :especie_id, :IdNombre
  alias_attribute :catalogo_id, :IdCatNombre
  alias_attribute :observaciones, :Observaciones

  attr_accessor :catalogo_id_falso
  belongs_to :especie
  belongs_to :catalogo, :foreign_key => Catalogo.attribute_alias(:id)

  has_many :especies_catalogos_bibliografias, :class_name => 'EspecieCatalogoBibliografia', :dependent => :destroy, :foreign_key => Especie.attribute_alias(:id)
end
