class Plantid::Bibliografia < ActiveRecord::Base
  self.table_name = "#{CONFIG.bases.plantid}.bibliografias"
  self.primary_key = 'id'

   # Los alias con las tablas de bibliografias
  alias_attribute :id, :id
  alias_attribute :nombre_biblio, :nombre_biblio

  has_and_belongs_to_many :plantas
end