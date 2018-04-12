class Estadistica < ActiveRecord::Base

  establish_connection(:development)
  self.table_name='enciclovida.estadisticas'

end
