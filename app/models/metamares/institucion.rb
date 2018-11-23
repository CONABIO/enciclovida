class Metamares::Institucion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.instituciones"

  belongs_to :ubicacion, class_name: 'Metamares::Ubicacion', inverse_of: :institucion
  has_one :proyecto, class_name: 'Metamares::Proyecto', inverse_of: :institucion

end