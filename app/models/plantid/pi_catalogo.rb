class Plantid::PiCatalogo < Plantid
  self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}catalogos"
  has_many :piplantacatalogos
  has_many :piplantas, through: :piplantacatalogos
end