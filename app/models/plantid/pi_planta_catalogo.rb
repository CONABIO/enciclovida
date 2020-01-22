class Plantid::PiPlantaCatalogo < Plantid
 self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}plantas_catalogos"

 belongs_to :picatalogo
 belongs_to :piplanta

end
