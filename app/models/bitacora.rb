class Bitacora < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.bitacoras"
  belongs_to :usuario

end
