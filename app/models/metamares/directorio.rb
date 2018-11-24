class Metamares::Directorio < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.directorio"

  belongs_to :metausuario, class_name: 'Metausuario'
  belongs_to :institucion, class_name: 'Metamares::Institucion'

end