class ExoticaInvasora < ActiveRecord::Base
  self.table_name = "exoticas_invasoras"

  belongs_to :especie

  has_many :documentos,
           class_name: "ExoticaDocumento",
           dependent: :destroy

  accepts_nested_attributes_for :documentos, allow_destroy: true,
                              reject_if: proc { |attributes|
                                attributes['tipo_documento_id'].blank? &&
                                attributes['archivo'].blank?
                              }

  has_many :exoticas_invasoras_catalogos,
           dependent: :destroy

  has_many :catalogos,
           through: :exoticas_invasoras_catalogos,
           source: :catalogo

  validates :especie_id,
            presence: true,
            uniqueness: {
              message: "Esta especie ya está registrada como exótica invasora."
            }

  def catalogos_por_tipo(tipo)
    catalogos.where(tipo: tipo)
  end

  def catalogo_ids_por_tipo(tipo)
    catalogos.where(tipo: tipo).pluck(:id)
  end

  def guardar_catalogos(tipo, ids)
    ids ||= []

    catalogo_ids = ExoticaCatalogo
      .where(tipo: tipo, activo: true)
      .pluck(:id)

    exoticas_invasoras_catalogos
      .where(catalogo_id: catalogo_ids)
      .destroy_all

    ids.reject(&:blank?).uniq.each do |id|
      exoticas_invasoras_catalogos.create!(
        catalogo_id: id
      )
    end
  end
end