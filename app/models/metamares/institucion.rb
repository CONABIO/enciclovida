class Metamares::Institucion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.instituciones"

  belongs_to :ubicacion, class_name: 'Metamares::Ubicacion', inverse_of: :institucion
  has_many :proyectos, class_name: 'Metamares::Proyecto'

  accepts_nested_attributes_for :ubicacion

end