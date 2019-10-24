class Plantid::Imagen < ActiveRecord::Base
  self.table_name = "#{CONFIG.bases.plantid}.imagenes"
  self.primary_key = 'id'

   # Los alias con las tablas de imagen
  alias_attribute :id, :id
  alias_attribute :nombre_orig, :nombre_orig
  alias_attribute :tipo, :tipo
  alias_attribute :ruta_relativa, :ruta_relativa


  has_and_belongs_to_many :plantas
end