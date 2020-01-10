class Plantid::Bibliografiaplantid < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.bibliografias"

  has_many :plantabibliografias, foreign_key: :bibliografia_id
  has_many :plantas, through: :plantabibliografias

end