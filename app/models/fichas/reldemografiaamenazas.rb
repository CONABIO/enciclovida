class Fichas::Reldemografiaamenazas < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.reldemografiaamenazas"
	self.primary_keys = :demografiaAmenazasId,  :amenazaId

	belongs_to :demografiaAmenazas, :class_name => 'Fichas::Demografiaamenazas', :foreign_key => 'demografiaAmenazasId'
	belongs_to :amenazaDirecta, :class_name => 'Fichas::Amenazadirecta', :foreign_key => 'amenazaId'

end
