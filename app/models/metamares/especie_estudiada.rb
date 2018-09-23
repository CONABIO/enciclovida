class Metamares::EspecieEstudiada < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.especies_estudiadas"

  belongs_to :proyecto, class_name: 'Metamares::Proyecto'
  belongs_to :especie, class_name: 'Especie'

end