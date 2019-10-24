class Plantid::Catalogo < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.catalogos"
  
  belongs_to :plantas
end