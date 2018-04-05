class Catalogo < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.CatalogoNombre'
  self.primary_key = 'IdCatNombre'

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdCatNombre
  alias_attribute :descripcion, :Descripcion
  alias_attribute :nivel1, :Nivel1
  alias_attribute :nivel2, :Nivel2
  alias_attribute :nivel3, :Nivel3
  alias_attribute :nivel4, :Nivel4
  alias_attribute :nivel5, :Nivel5

  scope :nom, -> { where(nivel1: 4, nivel2: 1).where("#{attribute_alias(:nivel3)} > 0") }
  scope :iucn, -> { where(nivel1: 4, nivel2: 2).where("#{attribute_alias(:nivel3)} > 0").where.not(descripcion: 'Riesgo bajo (LR): Dependiente de conservación (cd)') }
  scope :cites, -> { where(nivel1: 4, nivel2: 3).where("#{attribute_alias(:nivel3)} > 0") }
  scope :prioritarias, -> { where(nivel1: 4, nivel2: 4).where("#{attribute_alias(:nivel3)} > 0") }
  scope :ambientes, -> { where(:nivel1 => 2, :nivel2 => 6).where('nivel3 > 0').where.not(descripcion: AMBIENTE_EQUIV_MARINO) }

  AMBIENTE_EQUIV_MARINO = ['Nerítico', 'Nerítico y oceánico', 'Oceánico']

  # REVISADO:
  def self.ambiente_todos
    ambientes
  end

  # REVISADO: Las categorias de conservacion para la busqueda avanzada
  def self.nom_cites_iucn_todos
    nom = self.nom#.map(&:descripcion)
    nom = [nom[3],nom[1],nom[0],nom[2]]  # Orden propuesto por cgalindo
    iucn = self.iucn#.map(&:descripcion)
    iucn = [iucn[6],iucn[5],iucn[8],iucn[7],iucn[4],iucn[3],iucn[2],iucn[1],iucn[0]]  # Orden propuesto por cgalindo
    cites = self.cites#.map(&:descripcion) #Esta ya viene en orden (I,II,III)
    {:nom => nom, :iucn => iucn, :cites => cites}
  end

  def self.prioritaria_todas
    prioritarias
  end
end
