class Fichas::Taxon < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.taxon"
	self.primary_key = 'especieId'

	has_many :caracteristicasEspecies, :class_name => 'Fichas::Caracteristicasespecie', :foreign_key => 'especieId'
	has_many :conservacion, :class_name => 'Fichas::Conservacion', :foreign_key => 'especieId'
	has_many :demografiaAmenazas, :class_name=> 'Fichas::Demografiaamenazas', :foreign_key => 'especieId'
	has_many :distribuciones, :class_name => 'Fichas::Distribucion', :foreign_key => 'especieId'
  has_many :endemicas, :class_name => 'Fichas::Endemica', :foreign_key => 'especieId'
	has_many :habitats, class_name: 'Fichas::Habitat', :foreign_key => 'especieId'
	has_one :historiaNatural, class_name: 'Fichas::Historianatural', :foreign_key => 'especieId'
	has_many :legislaciones, class_name: 'Fichas::Legislacion', :foreign_key => 'especieId'
	has_many :metadatos, class_name: 'Fichas::Metadatos', :foreign_key => 'especieId'
	has_one :nombreComun, class_name: 'Fichas::Nombrecomun', :foreign_key => 'especieId'
	has_many :productoComercios, class_name: 'Fichas::Productocomercio', :foreign_key => 'especieId'
	has_many :sinonimos , class_name: 'Fichas::Sinonimo', :foreign_key => 'especieId'
	has_many :referenciasBibliograficas, class_name: 'Fichas::Referenciabibliografica', :foreign_key => 'especieId'

  has_one :scat, class_name: 'Scat', primary_key: :IdCAT, foreign_key: Scat.attribute_alias(:catalogo_id)
  has_one :especie, through: :scat, source: :especie

  # Devuelve las secciones que tienen información
	def dame_datos_edad_peso_largo
		datos = {}
		datos[:edad] = {}
		datos[:peso] = {}
		datos[:largo] = {}
		datos[:estatus] = false

		if edadinicialmachos.present? || edadfinalmachos.present? || edadinicialhembras.present? || edadfinalhembras.present?
			datos[:edad][:datos] = []
			datos[:edad][:datos][:estatus] = true
			datos[:estatus] = true
			datos[:edad][:datos][0] = edadinicialmachos
			datos[:edad][:datos][1] = edadfinalmachos
			datos[:edad][:datos][2] = edadinicialhembras
			datos[:edad][:datos][3] = edadfinalhembras
		end

		if pesoinicialmachos.present? || pesofinalmachos.present? || pesoinicialhembras.present? || pesofinalhembras.present?
			datos[:peso][:datos] = []
			datos[:peso][:datos][:estatus] = true
			datos[:estatus] = true
			datos[:peso][:datos][0] = pesoinicialmachos
			datos[:peso][:datos][1] = pesofinalmachos
			datos[:peso][:datos][2] = pesoinicialhembras
			datos[:peso][:datos][3] = pesofinalhembras
		end

		if largoinicialmachos.present? || largofinalmachos.present? || largoinicialhembras.present? || largofinalhembras.present?
			datos[:largo][:datos] = []
			datos[:largo][:datos][:estatus] = true
			datos[:estatus] = true
			datos[:largo][:datos][0] = largoinicialmachos
			datos[:largo][:datos][1] = largofinalmachos
			datos[:largo][:datos][2] = largoinicialhembras
			datos[:largo][:datos][3] = largofinalhembras
		end

		datos
	end

end