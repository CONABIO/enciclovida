class Fichas::Amenazadirecta < Ficha

  self.table_name = "#{CONFIG.bases.fichasespecies}.amenazadirecta"
  self.primary_key = 'amenazaId'

  has_many :relDemografiaAmenazas, class_name: 'Fichas::Reldemografiaamenazas', :foreign_key => "amenazaId"
  has_many :demografiaAmenazas, :class_name => 'Fichas::Demografiaamenazas', through: :relDemografiaAmenazas

end