class Scat < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.SCAT"
  self.primary_key = 'IdNombre'

  # Los alias con las tabla de SCAT
  alias_attribute :id, :IdNombre
  alias_attribute :catalogo_id, :IDCAT
  alias_attribute :publico, :Publico
  alias_attribute :nivel_de_revision, :Nivel_de_revision

  has_one :especie, foreign_key: Especie.attribute_alias(:id)

end
