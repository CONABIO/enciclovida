class Plantid::PiPlanta < Plantid
  self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}plantas"

  validates :especie_id, presence: true , length: {minimum: 1}
  validates :nombre_comun, presence: true, length: {maximum: 45}
  validates :usuario_id, presence: true

  has_many :piplantabibliografias, class_name: 'Plantid::PiPlantaBibliografia', inverse_of: :piplanta, foreign_key: :planta_id
  has_many :piplantacatalogos, class_name: 'Plantid::PiPlantaCatalogo', inverse_of: :planta, foreign_key: :planta_id
  has_many :piplantaimagenes, class_name: 'Plantid::PiPlantaImagen', inverse_of: :planta, foreign_key: :planta_id
  has_many :pibibliografias, class_name: 'Plantid::PiBibliografia', through: :piplantabibliografias, foreign_key: :bibliografia_id
  has_many :picatalogo, through: :piplantacatalogos, source: :picatalogo, foreign_key: :catalogo_id
  has_many :piimagen, class_name: 'Plantid::PiImagen', dependent: :destroy, through: :piplantaimagenes, foreign_key: :imagen_id

  accepts_nested_attributes_for :pibibliografias, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :picatalogo, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :piimagen, :reject_if => :all_blank, :allow_destroy => true

end
