class Plantid::Imagen < Plantidabs
	
  self.table_name = "#{CONFIG.bases.plantid}.imagenes"

  belongs_to :plantas
end