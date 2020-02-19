class Plantid::PiCatalogo < Plantid
  self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}catalogos"
  has_many :piplantacatalogos, foreign_key: :catalogo_id
  has_many :piplantas, through: :piplantacatalogos, foreign_key: :planta_id
end