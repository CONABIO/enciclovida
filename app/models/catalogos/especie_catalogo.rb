class EspecieCatalogo < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.RelNombreCatalogo"
  self.primary_keys = :IdCatNombre, :IdNombre

  # Los alias con las tablas de catalogos
  alias_attribute :especie_id, :IdNombre
  alias_attribute :catalogo_id, :IdCatNombre
  alias_attribute :observaciones, :Observaciones

  validates_uniqueness_of :IdCatNombre, :scope => [:IdNombre]

  attr_accessor :catalogo_id_falso
  belongs_to :especie, foreign_key: attribute_alias(:especie_id)
  belongs_to :catalogo, foreign_key: attribute_alias(:catalogo_id)

  has_many :biblios, :class_name => 'EspecieCatalogoBibliografia', :dependent => :destroy, :foreign_key => attribute_alias(:observaciones)
  
  # agregado en sept 2024 para solucionar lo de las bibliografias JM
  def biblios_con_dos_foreign_keys
    EspecieCatalogoBibliografia.where(catalogo_id: self.catalogo_id, especie_id: self.especie_id)
  end

end
