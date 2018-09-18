class Metamares::Dato < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.datos"

end