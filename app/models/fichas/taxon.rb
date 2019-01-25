class Fichas::Taxon < ActiveRecord::Base

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

end