class ExoticaCatalogo < ActiveRecord::Base
  self.table_name = "exoticas_catalogos"

  has_many :relaciones,
           class_name: "ExoticaInvasoraCatalogo",
           foreign_key: :catalogo_id,
           dependent: :destroy

  scope :activos, -> { where(activo: true).order(:orden, :nombre) }

  scope :grupos, -> { activos.where(tipo: "grupo") }
  scope :ambientes, -> { activos.where(tipo: "ambiente") }
  scope :origenes, -> { activos.where(tipo: "origen") }
  scope :presencias, -> { activos.where(tipo: "presencia") }
  scope :estatuses, -> { activos.where(tipo: "estatus") }
  scope :rutas, -> { activos.where(tipo: "ruta") }
  scope :instrumentos, -> { activos.where(tipo: "instrumento") }
  scope :tipos_documento, -> { activos.where(tipo: "tipo_documento") }

  validates :tipo, :clave, :nombre, presence: true
end