class Propiedad < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='propiedades'

  has_many :peces_propiedades, :class_name => 'PezPropiedad', :foreign_key => :propiedad_id
  has_many :peces, :through => :peces_propiedades, :source => :pez

  has_many :criterios, :class_name => 'Criterio', :foreign_key => :propiedad_id

  has_ancestry

  scope :grupos_conabio, -> { where(nombre_propiedad: 'Grupo CONABIO').first.children.order(:nombre_propiedad) }
  scope :tipo_capturas, -> { where('ancestry=?', 320) }
  scope :tipo_vedas, -> { where('ancestry=?', 321) }
  scope :procedencias, -> { where('ancestry=?', 322) }
  scope :pesquerias,  -> { where(tipo_propiedad: 'Pesquerías en vías de sustentabilidad') }
  scope :nom, -> { where('ancestry=?', 318) }
  scope :iucn, -> { where('ancestry=?', 319) }

  def self.zonas
    zonas = where(nombre_propiedad: 'Zonas').first.children
    zonas.each_with_index.map{|z, i| [z.nombre_propiedad, i+1]}
  end

  def nombre_zona_a_numero
    case nombre_propiedad
      when 'Pacífico I'
        0
      when 'Pacífico II'
        1
      when 'Pacífico III'
        2
      when 'Golfo de México y Caribe I'
        3
      when 'Golfo de México y Caribe II'
        4
      when 'Golfo de México y Caribe III'
        5
    end
  end

  def nombre_cnp_a_valor
    case nombre_propiedad
      when 'Estatus no definido'
        -20
      when 'No se distribuye'
        -10
      else
        nil
    end
  end

end