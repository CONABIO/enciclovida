class Plantid::PiPlantaImagen < Plantid
  self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}plantas_imagenes"

  belongs_to :piimagen, dependent: :destroy
  belongs_to :piplanta

end