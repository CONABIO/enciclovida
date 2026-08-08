class ExoticaInvasoraCatalogo < ActiveRecord::Base
  self.table_name = "exoticas_invasoras_catalogos"

  belongs_to :exotica_invasora

  belongs_to :catalogo,
             class_name: "ExoticaCatalogo",
             foreign_key: :catalogo_id
end