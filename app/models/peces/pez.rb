class Pez < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='peces'
  self.primary_key='especie_id'

  has_many :peces_criterios, :class_name => 'PezCriterio', :foreign_key => :especie_id
  has_many :criterios, :through => :peces_criterios, :source => :criterio

  has_many :peces_propiedades, :class_name => 'PezPropiedad', :foreign_key => :especie_id
  has_many :propiedades, :through => :peces_propiedades, :source => :propiedad

  belongs_to :especie

end