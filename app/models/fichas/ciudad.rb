class Fichas::Ciudad < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.ciudad"
	self.primary_key = 'ciudadId'

	belongs_to :pais, :class_name => 'Fichas::Pais', :foreign_key => 'paisId'
	has_many :contactos, :class_name => 'Fichas::Contacto'

end
