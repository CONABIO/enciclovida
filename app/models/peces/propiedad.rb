class Propiedad < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  self.table_name='propiedades'

  has_many :peces_propiedades, :class_name => 'PezPropiedad', :foreign_key => :propiedad_id
  has_many :peces, :through => :peces_propiedades, :source => :pez

  has_many :criterios, :class_name => 'Criterio', :foreign_key => :propiedad_id

  has_ancestry

  scope :grupos_conabio, -> { where('ancestry=?', GRUPO_ID).order(:nombre_propiedad) }
  scope :tipo_capturas, -> { where('ancestry=?', TIPO_CAPTURA_ID) }
  scope :tipo_vedas, -> { where('ancestry=?', TIPO_DE_VEDA_ID) }
  scope :procedencias, -> { where('ancestry=?', PROCEDENCIA_ID) }
  scope :pesquerias,  -> { where(tipo_propiedad: 'Pesquerías en vías de sustentabilidad') }
  scope :nom, -> { where('ancestry=?', NOM_ID) }
  scope :iucn, -> { where('ancestry=?', IUCN_ID) }
  scope :cnp, -> { where("ancestry REGEXP '323/31[123456]$'").where.not(tipo_propiedad: 'estado') }

  # Los IDS asignados, estos no deberían cambiar
  NOM_ID = 318.freeze
  IUCN_ID = 319.freeze
  TIPO_CAPTURA_ID = 320.freeze
  PROCEDENCIA_ID = 322.freeze
  TIPO_DE_VEDA_ID = 321.freeze
  ZONA_ID = 323.freeze
  GRUPO_ID = 317.freeze

  PROPIEDADES_DEFAULT = [NOM_ID, IUCN_ID, TIPO_CAPTURA_ID, PROCEDENCIA_ID, TIPO_DE_VEDA_ID, ZONA_ID].freeze

  def self.zonas
    zonas = where(nombre_propiedad: 'Zonas').first.children
    zonas.each_with_index.map{|z, i| [z.nombre_propiedad, i+1]}
  end

  def self.catalogo
    resp = Rails.cache.fetch('propiedades_catalogo', expires_in: eval(CONFIG.cache.peces.catalogos)) do
      grouped_options = {}

      Propiedad.all.each do |prop|

        next if prop.existe_propiedad?
        next if prop.is_root?
        llave_unica = prop.ancestors.map(&:nombre_propiedad).join('/')

        grouped_options[llave_unica] = [] unless grouped_options.key?(llave_unica)
        grouped_options[llave_unica] << [prop.nombre_propiedad, prop.id]
      end

      grouped_options
    end

    resp
  end

  def existe_propiedad?(propiedades=nil)
    propiedades ||= PROPIEDADES_DEFAULT
    return true if propiedades.include?(ancestry.to_i)
    false
  end

  def nombre_zona_a_numero
    case nombre_propiedad
      when 'Pacífico I'
        0
      when 'Pacífico II'
        1
      when 'Pacífico III'
        2
      when 'Golfo de México y Caribe IV'
        3
      when 'Golfo de México y Caribe V'
        4
      when 'Golfo de México y Caribe VI'
        5
    end
  end

end