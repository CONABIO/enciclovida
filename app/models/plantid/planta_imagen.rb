class Plantid::PlantaImagen < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.plantas_imagenes"

  belongs_to :imagen, dependent: :destroy
  belongs_to :planta

end