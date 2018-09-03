class Metamares::Directorio < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.directorio"

  belongs_to :usuario, class_name: 'Usuario'
  belongs_to :institucion, class_name: 'Metamares::Institucion'

end