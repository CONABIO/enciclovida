class Snib < ActiveRecord::Base

  self.abstract_class = true

  establish_connection(:snib)

end