class Fichas::Amenazadirecta < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.fichasespecies}.amenazadirecta"
  self.primary_key = 'amenazaId'
  has_many :relDemografiaAmenazas, class_name: 'Reldemografiaamenazas'

end