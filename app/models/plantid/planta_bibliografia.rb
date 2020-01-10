class Plantid::PlantaBibliografia < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.plantas_bibliografias"

  belongs_to :bibliografiaplantid, :class_name => 'Plantid::Bibliografiaplantid', foreign_key: :bibliografia_id
  belongs_to :planta

end