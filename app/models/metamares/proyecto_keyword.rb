class Metamares::ProyectoKeyword < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.proyectos_keywords"

  belongs_to :proyecto, class_name: 'Metamares::Proyecto'
  belongs_to :keyword, class_name: 'Metamares::Keyword'

end