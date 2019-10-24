class Plantid::Planta < Plantidabs

  self.table_name = "#{CONFIG.bases.plantid}.plantas"

  has_and_belongs_to_many :bibliografias
  has_and_belongs_to_many :catalogos
  has_and_belongs_to_many :imagenes

  accepts_nested_attributes_for :bibliografias, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :catalogos, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :imagenes, :reject_if => :all_blank, :allow_destroy => true

end
