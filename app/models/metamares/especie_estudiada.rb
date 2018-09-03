class Metamares::EspecieEstudiada < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.especies_estudiadas"

end