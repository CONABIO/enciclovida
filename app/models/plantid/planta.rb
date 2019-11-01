class Plantid::Planta < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.plantas"

  has_many :plantabibliografias, class_name: 'Plantid::PlantaBibliografia', inverse_of: :planta
  has_many :plantacatalogos, class_name: 'Plantid::PlantaCatalogo', inverse_of: :planta
  has_many :plantaimagenes, class_name: 'Plantid::PlantaImagen', inverse_of: :planta
  has_many :bibliografia, through: :plantabibliografias, source: :bibliografia
  has_many :catalogo,through: :plantacatalogos, source: :catalogo
  has_many :imagen, through: :plantaimagenes

  accepts_nested_attributes_for :bibliografia, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :catalogo, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :imagen, :reject_if => :all_blank, :allow_destroy => true

end
