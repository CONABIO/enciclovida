class EspecieCatalogoBibliografia < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name='RelNombreCatalogoBiblio'
  self.primary_keys = :IdNombre, :IdCatNombre, :IdBibliografia

  # Los alias con las tablas de catalogos
  alias_attribute :especie_id, :IdNombre
  alias_attribute :catalogo_id, :IdCatNombre
  alias_attribute :bibliografia_id, :IdBibliografia

end