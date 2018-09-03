class ProyectoM < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.proyectos"

  belongs_to :info_adicional, class_name: 'InfoAdicionalM'
  belongs_to :periodo, class_name: 'PeriodoM'
  belongs_to :region, class_name: 'RegionM'
  belongs_to :institucion, class_name: 'InstitucionM'
  belongs_to :dato, class_name: 'DatoM'
  belongs_to :usuario, class_name: 'Usuario'

end