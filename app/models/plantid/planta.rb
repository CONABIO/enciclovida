class Plantid::Planta < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.plantas"
  self.primary_key = 'id'

   # Los alias con las tablas de plantas
  alias_attribute :id, :id
  alias_attribute :especie_id, :especie_id 
  alias_attribute :nombre_cientifico, :nombre_cientifico
  alias_attribute :nombre_comun, :nombre_comun
  alias_attribute :nombres_comunes, :nombres_comunes
  alias_attribute :usuario_id, :usuario_id

  has_and_belongs_to_many :bibliografias
  has_and_belongs_to_many :catalogos
  has_and_belongs_to_many :imagenes

  accepts_nested_attributes_for :bibliografias, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :catalogos, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :imagenes, :reject_if => :all_blank, :allow_destroy => true

end
