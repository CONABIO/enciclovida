class Estadistica < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  self.table_name="#{Rails.configuration.database_configuration[Rails.env]['database']}.estadisticas"

end
