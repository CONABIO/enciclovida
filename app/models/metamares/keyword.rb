class Metamares::Keyword < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.keywords"

end