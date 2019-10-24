class Plantid::Catalogo < ActiveRecord::Base
  self.table_name = "#{CONFIG.bases.plantid}.catalogos"
  self.primary_key = 'id'

   # Los alias con las tablas de catalogo
  alias_attribute :id, :id
  alias_attribute :descripcion, :descripcion
  alias_attribute :categoria_principal, :categoria_principal
  alias_attribute :categoria_intermedia, :categoria_intermedia

  has_and_belongs_to_many :plantas
end