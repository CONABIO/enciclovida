class Pmc::PezCriterio < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.pez}.peces_criterios"

  belongs_to :pez, class_name: 'Pmc::Pez', foreign_key: :especie_id
  belongs_to :criterio

  validates_uniqueness_of :especie_id, scope: :criterio_id

end