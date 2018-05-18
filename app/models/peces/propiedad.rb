class Propiedad < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='propiedades'

  has_many :peces_propiedades, :class_name => 'PezPropiedad', :foreign_key => :propiedad_id
  has_many :peces, :through => :peces_propiedades, :source => :pez

  has_many :criterios, :class_name => 'Criterio', :foreign_key => :propiedad_id

  has_ancestry

  scope :grupos_conabio, -> { where(tipo_propiedad: 'Grupo CONABIO').order(:nombre_propiedad) }
  scope :zonas, -> { where(tipo_propiedad: 'zonas') }
  scope :tipo_capturas, -> { where(tipo_propiedad: 'Tipo de captura') }
  scope :tipo_vedas, -> { where(tipo_propiedad: 'Tipo de veda') }
  scope :procedencias, -> { where(tipo_propiedad: 'Procedencia') }
  scope :pesquerias, -> { select(:nombre_propiedad).where(tipo_propiedad: 'Pesquerías en vías de sustentabilidad ').distinct.order(:nombre_propiedad) }
  scope :cnp, -> { select(:nombre_propiedad).where(tipo_propiedad: ['zona pacifico', 'zona golfo y caribe']).distinct.order(:nombre_propiedad) }
  scope :nom, -> { where(tipo_propiedad: 'Norma Oficial Mexicana 059 SEMARNAT-2010') }
  scope :iucn, -> { where(tipo_propiedad: 'Lista roja IUCN 2016-3') }

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