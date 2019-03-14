class EspecieEstadistica < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.especies_estadistica"

  belongs_to :estadistica, inverse_of: :especie_estadisticas
  belongs_to :especie, :foreign_key => Especie.attribute_alias(:id), inverse_of: :especie_estadisticas

  scope :visitas, -> { where(estadistica_id: 1).first.conteo }

end