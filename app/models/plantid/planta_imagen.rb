class Plantid::PlantaImagen < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.plantas_imagenes"

  belongs_to :imagen
  belongs_to :planta

end