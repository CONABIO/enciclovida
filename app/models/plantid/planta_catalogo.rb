class Plantid::PlantaCatalogo < Plantidabs
 self.table_name = "#{CONFIG.bases.plantid}.plantas_catalogos"

 belongs_to :catalogo
 belongs_to :planta

end
