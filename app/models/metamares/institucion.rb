class Metamares::Institucion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.instituciones"

  belongs_to :ubicacion, class_name: 'Metamares::Ubicacion'

end