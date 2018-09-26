class Metamares::Metadata < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.metadata"

end