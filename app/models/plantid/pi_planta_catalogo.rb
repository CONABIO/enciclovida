class Plantid::PiPlantaCatalogo < Plantid
 self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}plantas_catalogos"

 belongs_to :picatalogo, class_name: 'Plantid::PiCatalogo', foreign_key: :catalogo_id
 belongs_to :piplanta, class_name: 'Plantid::PiPlanta', foreign_key: :planta_id

end
