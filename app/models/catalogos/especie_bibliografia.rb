class EspecieBibliografia < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.RelNombreBiblio'
  self.primary_keys = 'IdNombre, IdBibliografia'

  # Los alias con las tablas de catalogos
  alias_attribute :especie_id, :IdNombre
  alias_attribute :bibliografia_id, :IdBibliografia
  alias_attribute :observaciones, :Observaciones

  belongs_to :bibliografia, :foreign_key => Bibliografia.attribute_alias(:id)
end
