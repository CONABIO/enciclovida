class Metamares::Ubicacion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.ubicaciones"

  has_one :institucion, class_name: 'Metamares::Institucion', inverse_of: :ubicacion
  has_many :proyectos, through: :institucion, source: :proyecto

  validates_presence_of :institucion
end