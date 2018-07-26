class Estadistica < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  self.table_name='enciclovida.estadisticas'

end
