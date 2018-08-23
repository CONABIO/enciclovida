class Bitacora < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  self.table_name='bitacoras'
  belongs_to :usuario

end
