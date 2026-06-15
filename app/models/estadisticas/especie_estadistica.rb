class EspecieEstadistica < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.especies_estadistica"
  self.primary_key = :id

  belongs_to :estadistica, inverse_of: :especie_estadisticas
  belongs_to :especie, :foreign_key => Especie.attribute_alias(:id), inverse_of: :especie_estadisticas

  scope :visitas, -> { find_by(estadistica_id: 1)&.conteo || 0 }

end