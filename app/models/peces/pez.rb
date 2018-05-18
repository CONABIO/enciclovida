class Pez < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='peces'
  self.primary_key='especie_id'

  has_many :peces_criterios, :class_name => 'PezCriterio', :foreign_key => :especie_id
  has_many :criterios, :through => :peces_criterios, :source => :criterio

  has_many :peces_propiedades, :class_name => 'PezPropiedad', :foreign_key => :especie_id
  has_many :propiedades, :through => :peces_propiedades, :source => :propiedad

  belongs_to :especie

  scope :join_criterios,-> { joins('LEFT JOIN peces_criterios ON peces.especie_id=peces_criterios.especie_id LEFT JOIN criterios on peces_criterios.criterio_id = criterios.id') }
  scope :join_propiedades,-> { joins('LEFT JOIN peces_propiedades ON peces.especie_id=peces_propiedades.especie_id LEFT JOIN propiedades on peces_propiedades.propiedad_id = propiedades.id') }
  scope :select_peces, -> { select("peces.especie_id, peces.valor_total_promedio, criterios.valor, criterios.anio, propiedades.nombre_propiedad, propiedades.tipo_propiedad, propiedades.ancestry")}

  def self.cruceEspecies(ids=nil)
    ids = select('especie_id').map(&:especie_id) if ids.nil?
    Especie.find(ids)
  end

end