class MetadatoEspecie < ActiveRecord::Base
  self.table_name = :metadato_especies

  belongs_to :especie
  belongs_to :metadato
end