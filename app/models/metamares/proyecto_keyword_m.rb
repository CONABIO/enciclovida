class ProyectoKeywordM < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.proyectos_keywords"

  belongs_to :proyecto, class_name: 'ProyectoM'
  belongs_to :keyword, class_name: 'KeywordM'

end