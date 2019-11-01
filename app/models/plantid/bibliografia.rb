class Plantid::Bibliografia < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.bibliografias"


  has_many :plantabibliografias
  has_many :plantas, through: :plantabibliografias
end