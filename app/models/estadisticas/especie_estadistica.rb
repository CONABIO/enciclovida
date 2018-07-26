class EspecieEstadistica < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  self.table_name='enciclovida.especies_estadistica'

  belongs_to :estadistica, :foreign_key => Estadistica.attribute_alias(:id)
  belongs_to :especie, :foreign_key => Especie.attribute_alias(:id)

  scope :visitas, -> { where(estadistica_id: 1).first.conteo }

end