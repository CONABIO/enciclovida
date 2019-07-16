class Fichas::Caracteristicasespecie < Ficha

	self.table_name = "#{CONFIG.bases.fichasespecies}.caracteristicasespecie"
	self.primary_keys = :especieId,  :idpregunta,  :idopcion

	belongs_to :taxon, :class_name => 'Fichas::Taxon', :foreign_key => 'especieId'
	#belongs_to :clima, :class_name => 'Fichas::Tipoclima', :foreign_key => 'idopcion'
	#belongs_to :suelo, :class_name => 'Fichas::Suelo', :foreign_key => 'idopcion'
	#belongs_to :geoforma, :class_name => 'Fichas::Geoforma', :foreign_key => 'idopcion'

	belongs_to :clima, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :suelo, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :geoforma, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :tipoVegetacionSecundaria, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :tipoVegetacionMundial, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :ecorregionMarinaN1, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :zonaVida, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :habitoPlantas, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :forrajeo, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :migracion, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :tipoMigracion, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :habito, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :sistapareamiento, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :sitioanidacion, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :arregloespacialflores, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :arregloespacialindividuos, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :arregloespacialpoblaciones, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :vectorespolinizacion, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :agentespolinizacion, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :structdisp, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :dispersionsei, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :interacciones, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :comnalsel, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :esquemamanejo, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :tipopesca, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :regioncaptura, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :artepesca, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :acuacultura, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :mecanismos, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :efectoimpactosei, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :intensidadimpactosei, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :naturalizacionsei, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :especiesasociadassei, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :plasticidadsei, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :platenciasei, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :seguridadsei, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'
	belongs_to :enfermedadessei, :class_name => 'Fichas::Cat_Preguntas', :foreign_key => 'idopcion'

end



=begin

SECCION AMBIENTE
a) Indicar el o los tipos de vegetación
en los que se desarrolla la especie:
 SELECT descripcionVegetacion FROM vegetacion GROUP BY descripcionVegetacion
a) Indicar el o los tipos de vegetación
en los que se desarrolla la especie: EXO:
SELECT descripcionVegetacion FROM vegetacion GROUP BY descripcionVegetacion;
b) Hábitats antrópicos:
$sql = "SELECT idopcion, descn1 FROM cat_preguntas WHERE idpregunta = '1';";

has_many :tipoVegetacionSecundaria,-> {where('caracteristicasespecie.idpregunta = ?', 2)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :tipoVegetacionMundial,-> {where('caracteristicasespecie.idpregunta = ?', 3)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :clima,-> {where('caracteristicasespecie.idpregunta = ?', 4)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :climaExo,-> {where('caracteristicasespecie.idpregunta = ?', 5)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :suelo,-> {where('caracteristicasespecie.idpregunta = ?', 6)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :geoforma,-> {where('caracteristicasespecie.idpregunta = ?', 7)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :ecorregionMarinaN1,-> {where('caracteristicasespecie.idpregunta = ?', 44)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :zonaVida,-> {where('caracteristicasespecie.idpregunta = ?', 43)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

c) Hábitat acuático:
"SELECT vegetacion FROM vegetacionacuatica GROUP BY vegetacion;";





IV. Biología de la especie

has_many :habitoPlantas,-> {where('caracteristicasespecie.idpregunta = ?', 45)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :tipoAlimentacion,-> {where('caracteristicasespecie.idpregunta = ?', 9)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

Estrategia trófica
SELECT * FROM cat_estrategiatrofica;

has_many :forrajeo,-> {where('caracteristicasespecie.idpregunta = ?', 8)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

has_many :migracion,-> {where('caracteristicasespecie.idpregunta = ?', 10)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :tipoMigracion,-> {where('caracteristicasespecie.idpregunta = ?', 11)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :habito,-> {where('caracteristicasespecie.idpregunta = ?', 12)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies


h) Mecanismos de defensa
"Alelopatía"
"Coloración"
"Defensa química"
"Espinas"
"Mimetismo"
"Veneno"

i) Organización social:
"Colonias"
"Familia"
"Grupo"
"Manadas"
"Solitarios"
"Card&uacute;menes"
"Eusocial"
"Filopatría-machos"
"Filopatría-hembras"
"Quasisocial"
"Semisocial"




---------- A N I M A L

has_many :sistapareamiento,-> {where('caracteristicasespecie.idpregunta = ?', 13)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

d) Número de eventos reproductivos:
"Iteróparos"
"Semélparos"


f) Tipo de fecundación:
"Interna"
"Externa"

has_many :sitioanidacion,-> {where('caracteristicasespecie.idpregunta = ?', 14)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

l) Cuidado parental:
"hembra"
"macho"
"ambos"




--------- V E G E T A L

has_many :arregloespacialflores,-> {where('caracteristicasespecie.idpregunta = ?', 49)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :arregloespacialindividuos,-> {where('caracteristicasespecie.idpregunta = ?', 50)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :arregloespacialpoblaciones,-> {where('caracteristicasespecie.idpregunta = ?', 51)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies



c) Aislamiento temporal o espacial de los órganos reproductores:
"Dicogamia"
"Protandria"
"Protoginia"
"Hercogamia"


d) Sistemas reproductivos asexuales
"Multiplicaci&oacute;n vegetativa"
"Esporulaci&oacute;n"
"Apomixis"

e) Tipo de fecundación:
"Alogamia"
"Autogamia"
"Cleistogamia "

f) Tipo de polinización:
has_many :vectorespolinizacion,-> {where('caracteristicasespecie.idpregunta = ?', 53)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
i. Vectores de polinización:
has_many :agentespolinizacion,-> {where('caracteristicasespecie.idpregunta = ?', 48)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies


i. Horario de apertura de la flor:
"Diurno"
"Crepuscular"
"Nocturno"


iii. Características del fruto:
"SELECT * FROM cat_caracfruto;"


has_many :tipodispersion,-> {where('caracteristicasespecie.idpregunta = ?', 15)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :structdisp,-> {where('caracteristicasespecie.idpregunta = ?', 16)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies

Riesgo de dispersi&oacute;n
has_many :dispersionsei,-> {where('caracteristicasespecie.idpregunta = ?', 39)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies



V. Ecología y demografía de la especie

d) Descripción del patrón de ocupación:
"Agregada"
"Uniforme"
"Al azar"
has_many :interacciones,-> {where('caracteristicasespecie.idpregunta = ?', 17)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies



VII. Importancia de la especie
b) Función ecológica:
"Productores"
"Depredador"
"Depredador tope"
"Descomponedor"
"Dispersor"
"Polinizador"
"Fijadores de carbono"
"Fijadores de nitr&oacute;geno"
"Otros"

Origen de los especímenes
has_many :comnalsel,-> {where('caracteristicasespecie.idpregunta = ?', 18)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies



has_many :esquemamanejo,-> {where('caracteristicasespecie.idpregunta = ?', 26)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :tipopesca,-> {where('caracteristicasespecie.idpregunta = ?', 28)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
has_many :regioncaptura,-> {where('caracteristicasespecie.idpregunta = ?', 29)}, class_name: 'Fichas::Cat_Preguntas', through: :caracteristicasEspecies
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

accepts_nested_attributes_for :tipoVegetacionSecundaria, allow_destroy: true
accepts_nested_attributes_for :tipoVegetacionMundial, allow_destroy: true
accepts_nested_attributes_for :ecorregionMarinaN1, allow_destroy: true
accepts_nested_attributes_for :zonaVida, allow_destroy: true
accepts_nested_attributes_for :habitoPlantas, allow_destroy: true
accepts_nested_attributes_for :tipoAlimentacion, allow_destroy: true
accepts_nested_attributes_for :forrajeo, allow_destroy: true
accepts_nested_attributes_for :migracion, allow_destroy: true
accepts_nested_attributes_for :tipoMigracion, allow_destroy: true
accepts_nested_attributes_for :habito, allow_destroy: true
accepts_nested_attributes_for :sistapareamiento, allow_destroy: true
accepts_nested_attributes_for :sitioanidacion, allow_destroy: true
accepts_nested_attributes_for :arregloespacialflores, allow_destroy: true
accepts_nested_attributes_for :arregloespacialindividuos, allow_destroy: true
accepts_nested_attributes_for :arregloespacialpoblaciones, allow_destroy: true
accepts_nested_attributes_for :vectorespolinizacion, allow_destroy: true
accepts_nested_attributes_for :agentespolinizacion, allow_destroy: true
accepts_nested_attributes_for :structdisp, allow_destroy: true
accepts_nested_attributes_for :dispersionsei, allow_destroy: true
accepts_nested_attributes_for :interacciones, allow_destroy: true
accepts_nested_attributes_for :comnalsel, allow_destroy: true
accepts_nested_attributes_for :esquemamanejo, allow_destroy: true
accepts_nested_attributes_for :tipopesca, allow_destroy: true
accepts_nested_attributes_for :regioncaptura, allow_destroy: true
accepts_nested_attributes_for :artepesca, allow_destroy: true
accepts_nested_attributes_for :acuacultura, allow_destroy: true
accepts_nested_attributes_for :mecanismos, allow_destroy: true
accepts_nested_attributes_for :efectoimpactosei, allow_destroy: true
accepts_nested_attributes_for :intensidadimpactosei, allow_destroy: true
accepts_nested_attributes_for :naturalizacionsei, allow_destroy: true
accepts_nested_attributes_for :especiesasociadassei, allow_destroy: true
accepts_nested_attributes_for :plasticidadsei, allow_destroy: true
accepts_nested_attributes_for :platenciasei, allow_destroy: true
accepts_nested_attributes_for :seguridadsei, allow_destroy: true
accepts_nested_attributes_for :enfermedadessei, allow_destroy: true





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
