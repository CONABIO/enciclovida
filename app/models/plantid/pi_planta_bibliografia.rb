class Plantid::PiPlantaBibliografia < Plantid
  self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}plantas_bibliografias"

  belongs_to :pibibliografia, :class_name => 'Plantid::PiBibliografia', foreign_key: :bibliografia_id
  belongs_to :piplanta,:class_name => 'Plantid::PiPlanta',foreign_key: :planta_id

end