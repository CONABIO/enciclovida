class Metamares::ProyectoEspecie < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.proyectos_especies"

  belongs_to :proyecto, class_name: 'Metamares::Proyecto'
  belongs_to :especie_estudiada, class_name: 'Metamares::EspecieEstudiada'

end