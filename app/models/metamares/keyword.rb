class Metamares::Keyword < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.keywords"

  belongs_to :proyecto, class_name: 'Metamares::Proyecto'

end