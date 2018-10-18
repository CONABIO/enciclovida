class Ficha < ActiveRecord::Base

  self.abstract_class = true

  establish_connection(:fichasespecies)

end