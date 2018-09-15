class Metamares::Proyecto < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.proyectos"

  belongs_to :info_adicional, class_name: 'Metamares::InfoAdicional'
  belongs_to :periodo, class_name: 'Metamares::Periodo'
  belongs_to :region, class_name: 'Metamares::RegionM'
  belongs_to :institucion, class_name: 'Metamares::Institucion'
  belongs_to :dato, class_name: 'Metamares::Dato'
  belongs_to :usuario, class_name: 'Usuario'

end