class Estadistica < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.estadisticas"

  has_many :especie_estadisticas, class_name: 'EspecieEstadistica', inverse_of: :estadistica

end
