class Plantid::Planta < Plantidabs

  self.table_name = "#{CONFIG.bases.plantid}.plantas"

  has_many :bibliografias, inverse_of: :planta
  has_many :catalogos
  has_many :imagenes

  accepts_nested_attributes_for :bibliografias, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :catalogos, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :imagenes, :reject_if => :all_blank, :allow_destroy => true

end
