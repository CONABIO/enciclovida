class PezPropiedad < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.pez}.peces_propiedades"

  belongs_to :pez, class_name: 'Pez', foreign_key: :especie_id
  belongs_to :propiedad

  validates_uniqueness_of :especie_id, scope: :propiedad_id
end