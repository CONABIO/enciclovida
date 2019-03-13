class Geoportal < ActiveRecord::Base

  self.abstract_class = true
  establish_connection(:geoportal)

end