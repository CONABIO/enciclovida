class Admin::Catalogo < Catalogo

  has_many :especies_catalogo, class_name: Admin::EspecieCatalogo, foreign_key: attribute_alias(:id), inverse_of: :catalogo
  has_many :especies, -> { order(:nombre_cientifico) }, through: :especies_catalogo, source: :especie
  has_many :bibliografias_catalogo, through: :especies_catalogo
  has_many :bibliografias_especie, through: :especies_catalogo
  #has_many :bibliografias, through: :especies_catalogo

  scope :usos_count, -> { select(:id, :descripcion).select('COUNT(*) AS totales').group(:id, :descripcion) }
  scope :usos, -> { usos_count.joins(:especies_catalogo).where(nivel1: 11).order(:descripcion) }

  accepts_nested_attributes_for :especies_catalogo, reject_if: :all_blank, allow_destroy: true
    #accepts_nested_attributes_for :bibliografiaws, reject_if: :all_blank, allow_destroy: true

  #def bibliografias
  #  bibliografias_catalogo + bibliografias_especie
  #end

end
