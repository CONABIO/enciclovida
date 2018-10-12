class Metamares::Ubicacion < ActiveRecord::Base

  belongs_to :proyecto

  self.table_name = "#{CONFIG.bases.metamares}.ubicaciones"

end