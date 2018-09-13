class Estadistica < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.estadisticas"

end
