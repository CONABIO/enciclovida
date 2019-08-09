class Fichas::Cat_Preguntas < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.cat_preguntas"
	self.primary_key = 'idopcion'

	has_many :t_geoforma,-> {where('caracteristicasespecie.idpregunta = ?', Fichas::Caracteristicasespecie::OPCIONES[:geoforma])},  class_name: 'Fichas::Caracteristicasespecie', foreign_key: 'idopcion'
	has_many :t_tipoVegetacionSecundaria,-> {where('caracteristicasespecie.idpregunta = ?',  Fichas::Caracteristicasespecie::OPCIONES[:tipoVegetacionSecundaria])},  class_name: 'Fichas::Caracteristicasespecie', foreign_key: 'idopcion'

end