class Admin::Catalogo < Catalogo

  has_many :especies_catalogos, class_name: Admin::EspecieCatalogo, foreign_key: attribute_alias(:id)
  has_many :especies, through: :especies_catalogos

  scope :usos_count, -> { select(:id, :descripcion).select('COUNT(*) AS totales').group(:id, :descripcion) }
  scope :usos, -> { usos_count.joins(:especies_catalogos).where(nivel1: 11).order(:descripcion) }

end
