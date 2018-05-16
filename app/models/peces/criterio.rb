class Criterio < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='criterios'

  has_many :peces_criterios, :class_name => 'PezCriterio', :foreign_key => :criterio_id
  has_many :peces, :through => :peces_criterios, :source => :pez

  belongs_to :propiedad

end