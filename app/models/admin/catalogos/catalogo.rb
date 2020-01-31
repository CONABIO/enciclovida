class Admin::Catalogo < Catalogo

  attr_accessor :ajax

  has_many :especies_catalogo, class_name: Admin::EspecieCatalogo, foreign_key: attribute_alias(:id), inverse_of: :catalogo
  has_many :especies, -> { order(:nombre_cientifico) }, through: :especies_catalogo, source: :especie

  scope :usos_count, -> { select(:id, :descripcion).select('COUNT(*) AS totales').group(:id, :descripcion) }
  scope :usos, -> { usos_count.joins(:especies_catalogo).where(nivel1: 11).order(:descripcion) }

  def dame_nivel1
    Admin::Catalogo.where(nivel2: 0, nivel3: 0, nivel4: 0, nivel5: 0).where("#{Catalogo.attribute_alias(:nivel1)} > ?", 1).order(:descripcion).map{ |c| [c.descripcion, c.nivel1] }
  end

  def dame_nivel2
    return [] unless (nivel2.present? || ajax.present?)
    Admin::Catalogo.where(nivel1: nivel1, nivel3: 0, nivel4: 0, nivel5: 0).where("#{Catalogo.attribute_alias(:nivel2)} > ?", 0).order(:descripcion).map{ |c| [c.descripcion, c.nivel2] }
  end

  def dame_nivel3
    return [] unless (nivel3.present? || ajax.present?)
    Admin::Catalogo.where(nivel1: nivel1, nivel2: nivel2, nivel4: 0, nivel5: 0).where("#{Catalogo.attribute_alias(:nivel3)} > ?", 0).order(:descripcion).map{ |c| [c.descripcion, c.nivel3] }
  end

  def dame_nivel4
    return [] unless (nivel4.present? || ajax.present?)
    Admin::Catalogo.where(nivel1: nivel1, nivel2: nivel2, nivel3: nivel3, nivel5: 0).where("#{Catalogo.attribute_alias(:nivel4)} > ?", 0).order(:descripcion).map{ |c| [c.descripcion, c.nivel4] }
  end

  def dame_nivel5
    return [] unless (nivel5.present? || ajax.present?)
    Admin::Catalogo.where(nivel1: nivel1, nivel2: nivel2, nivel3: nivel3, nivel4: nivel4).where("#{Catalogo.attribute_alias(:nivel5)} > ?", 0).order(:descripcion).map{ |c| [c.descripcion, c.nivel5] }
  end

  accepts_nested_attributes_for :especies_catalogo, reject_if: :all_blank, allow_destroy: true

end
