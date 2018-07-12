class Distribucion < ActiveRecord::Base

	establish_connection(:fichasespecies)

 	# Asignación de tabla
	self.table_name = 'distribucion'

	self.primary_keys = :distribucionId,  :especieId

	belongs_to :taxon, :class_name => 'Taxon', :foreign_key => 'especieId'

	has_many :relDistribucionesEstados, class_name: 'Reldistribucionestado'
	has_many :relDistribucionesMunicipios, class_name: 'Reldistribucionmunicipio'
	has_many :relDistribucionesPaises, class_name: 'Reldistribucionpais'
end
