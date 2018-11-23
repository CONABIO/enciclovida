class Metamares::Ubicacion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.ubicaciones"

  has_one :institucion, class_name: 'Metamares::Institucion'
  has_many :proyectos, through: :institucion, source: :proyecto, inverse_of: :ubicacion

end