class Bitacora < ActiveRecord::Base
  self.table_name='bitacoras'
  belongs_to :usuario
end
