class Plantid::Imagen < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.imagenes"

  has_many :plantaimagenes
  has_many :plantas,through: :plantaimagenes

  mount_uploader :imagen, ImagenUploader

  before_save :completa_metadatos

  def completa_metadatos
  	self.nombre_orig = self.imagen.file.basename
  	self.ruta_relativa = self.imagen.url
  	self.tipo = self.imagen.file.extension
  end

  def validar_norebundacia
      #Bibliografia.exists?(CitaCompleta: self.)
  end

end