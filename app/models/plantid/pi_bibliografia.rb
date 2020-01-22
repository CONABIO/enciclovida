class Plantid::PiBibliografia < Plantid
  self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}bibliografias"

  has_many :piplantabibliografias, foreign_key: :bibliografia_id
  has_many :piplantas, through: :piplantabibliografias

end