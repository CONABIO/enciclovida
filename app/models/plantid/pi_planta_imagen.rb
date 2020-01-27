class Plantid::PiPlantaImagen < Plantid
  self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}plantas_imagenes"

  belongs_to :piimagen, dependent: :destroy,class_name: 'Plantid::PiImagen', foreign_key: :imagen_id
  belongs_to :piplanta, class_name: 'Plantid::PiPlanta', foreign_key: :planta_id

end