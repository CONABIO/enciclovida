class Plantid::Catalogo < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.catalogos"
  has_many :plantacatalogos
  has_many :plantas, through: :plantacatalogos
end