class Scat < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.SCAT'
  self.primary_key = 'IdNombre'

  # Los alias con las tabla de SCAT
  alias_attribute :id, :IdNombre
  alias_attribute :catalogo_id, :IDCAT
  alias_attribute :publico, :Publico
  alias_attribute :nivel_de_revision, :Nivel_de_revision

end
