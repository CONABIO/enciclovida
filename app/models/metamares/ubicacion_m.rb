class UbicacionM < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.ubicaciones"

end