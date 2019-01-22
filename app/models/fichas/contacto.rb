class Fichas::Contacto < ActiveRecord::Base

	self.table_name = "#{CONFIG.bases.fichasespecies}.contacto"
	self.primary_key = 'contactoId'

	belongs_to :ciudad, :class_name => 'Fichas::Ciudad', :foreign_key => 'ciudadId'
	has_many :relAsociadosContactos, class_name: 'Fichas::Relasociadocontacto'

end
