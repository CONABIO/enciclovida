class Plantid::Imagen < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.imagenes"

  has_many :plantaimagenes
  has_many :plantas, through: :plantaimagenes

end