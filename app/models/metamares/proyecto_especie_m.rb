class ProyectoEspecieM < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.proyectos_especies"

  belongs_to :proyecto, class_name: 'ProyectoM'
  belongs_to :especie_estudiada, class_name: 'EspecieEstudiadaM'

end