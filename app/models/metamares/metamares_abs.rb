class MetamaresAbs < ActiveRecord::Base

  self.abstract_class = true
  establish_connection :metamares

end