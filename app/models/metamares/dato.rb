class Metamares::Dato < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.datos"

  ESTATUS_DATOS = ['Public access'.to_sym, 'Restricted access'.to_sym, 'Private access'.to_sym]

end