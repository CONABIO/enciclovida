class Fichas::Caracteristicasespecie < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.caracteristicasespecie"
	self.primary_keys = :especieId,  :idpregunta,  :idopcion

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'

  # DESDE HABITAT
	belongs_to :t_tipoVegetacionSecundaria,-> {where('caracteristicasespecie.idpregunta = ?', 2)}, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :t_clima,-> {where('caracteristicasespecie.idpregunta = ?', 4)}, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :t_suelo,-> {where('caracteristicasespecie.idpregunta = ?', 6)}, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :t_geoforma,-> {where('caracteristicasespecie.idpregunta = ?', 7)}, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :t_habitatAntropico,-> {where('caracteristicasespecie.idpregunta = ?', 1)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :t_ecorregionMarinaN1,-> {where('caracteristicasespecie.idpregunta = ?', 44)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :t_zonaVida,-> {where('caracteristicasespecie.idpregunta = ?', 43)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'

  # DESDE HISTORIA NATURAL
  belongs_to :t_habitoPlantas,-> {where('caracteristicasespecie.idpregunta = ?', 45)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_alimentacion,-> {where('caracteristicasespecie.idpregunta = ?', 9)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_forrajeo,-> {where('caracteristicasespecie.idpregunta = ?', 8)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_migracion,-> {where('caracteristicasespecie.idpregunta = ?', 10)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_tipo_migracion,-> {where('caracteristicasespecie.idpregunta = ?', 11)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_habito,-> {where('caracteristicasespecie.idpregunta = ?', 12)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_tipodispersion,-> {where('caracteristicasespecie.idpregunta = ?', 15)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_structdisp,-> {where('caracteristicasespecie.idpregunta = ?', 16)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_dispersionsei,-> {where('caracteristicasespecie.idpregunta = ?', 39)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_comnalsel,-> {where('caracteristicasespecie.idpregunta = ?', 18)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_proposito_com,-> {where('caracteristicasespecie.idpregunta = ?', 20)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_comintersel,-> {where('caracteristicasespecie.idpregunta = ?', 22)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_proposito_com_int,-> {where('caracteristicasespecie.idpregunta = ?', 24)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'

  # DESDE Conservacion
  belongs_to :t_esquemamanejo,-> {where('caracteristicasespecie.idpregunta = ?', 26)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_tipopesca,-> {where('caracteristicasespecie.idpregunta = ?', 28)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_regioncaptura,-> {where('caracteristicasespecie.idpregunta = ?', 29)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'

  # DESDE REPRODUCCION VEGETAL
  belongs_to :t_arregloespacialflores,-> {where('caracteristicasespecie.idpregunta = ?', 49)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_arregloespacialindividuos,-> {where('caracteristicasespecie.idpregunta = ?', 50)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_arregloespacialpoblaciones,-> {where('caracteristicasespecie.idpregunta = ?', 51)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_vectorespolinizacion,-> {where('caracteristicasespecie.idpregunta = ?', 53)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
  belongs_to :t_agentespolinizacion,-> {where('caracteristicasespecie.idpregunta = ?', 48)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'

	# DESDE REPRODUCCION ANIMAL
	belongs_to :t_sistapareamiento,-> {where('caracteristicasespecie.idpregunta = ?', 13)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :t_sitioanidacion,-> {where('caracteristicasespecie.idpregunta = ?', 14)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'

	# DESDE DEMOGRAFIA AMENAZAS
	belongs_to :t_interacciones,-> {where('caracteristicasespecie.idpregunta = ?', 17)}, class_name: 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'

	OPCIONES = {
			:habitatAntropico => 1,
			:vegetacionSecundaria => 2,
			:clima => 4,
			:suelo => 6,
			:geoforma => 7,
      :forrajeo => 8,
      :alimentacion => 9,
      :migracion => 10,
      :tipo_migracion => 11,
      :habito => 12,
			:sistapareamiento => 13,
			:sitioanidacion => 14,
      :tipodispersion => 15,
      :structdisp => 16,
			:interacciones => 17,
      :comnalsel => 18,
      :proposito_com => 20,
      :comintersel => 22,
      :proposito_com_int => 24,
      :esquemamanejo => 26,
      :tipopesca => 28,
      :regioncaptura => 29,
      :dispersionsei => 39,
			:zonaVida => 43,
			:ecorregionMarinaN1 => 44,
      :habitoPlantas => 45,
      :agentespolinizacion => 48,
      :arregloespacialflores => 49,
      :arregloespacialindividuos => 50,
      :arregloespacialpoblaciones => 51,
      :vectorespolinizacion => 53
	}

end



=begin



has_many :artepesca,-> {where('caracteristicasespecie.idpregunta = ?', 30)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :acuacultura,-> {where('caracteristicasespecie.idpregunta = ?', 31)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :mecanismos,-> {where('caracteristicasespecie.idpregunta = ?', 33)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :efectoimpactosei,-> {where('caracteristicasespecie.idpregunta = ?', 34)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :intensidadimpactosei,-> {where('caracteristicasespecie.idpregunta = ?', 35)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :naturalizacionsei,-> {where('caracteristicasespecie.idpregunta = ?', 36)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :especiesasociadassei,-> {where('caracteristicasespecie.idpregunta = ?', 37)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :plasticidadsei,-> {where('caracteristicasespecie.idpregunta = ?', 38)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :platenciasei,-> {where('caracteristicasespecie.idpregunta = ?', 40)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :seguridadsei,-> {where('caracteristicasespecie.idpregunta = ?', 41)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :enfermedadessei,-> {where('caracteristicasespecie.idpregunta = ?', 42)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies


generamultiselectn2($varupdate, $controlname, $pregunta, $texto)
USA OPTGROUP
$sql = "SELECT descn1 FROM cat_preguntas where idpregunta = '".$pregunta."' GROUP BY descn1;";
$Uclima, "clima", "4", "tipo clima "); ?>
$Uclimaexo, "climaexo", "5", "tipo clima "); ?>
$Urutasei, "rutasei", "32","ruta ");?>





generamultiselectn3($varupdate, $controlname, $pregunta, $texto)
$sql2 = "SELECT idopcion, descn1, descn2, descn3 FROM cat_preguntas WHERE descn1='$registro[0]' and idpregunta = ".$pregunta.";";
generamultiselectn3($Ualimentacion, "alimenta", "9", "alimentaci�n "); ?>


=end
