class Plantid::PiImagen < Plantid
  self.table_name = "#{CONFIG.bases.plantid}.#{self.table_name_prefix}imagenes"

  has_many :piplantaimagenes,foreign_key: :imagen_id
  has_many :piplantas,through: :piplantaimagenes, foreign_key: :planta_id

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