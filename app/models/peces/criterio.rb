class Criterio < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='criterios'

  has_many :peces_criterios, :class_name => 'PezCriterio', :foreign_key => :criterio_id
  has_many :peces, :through => :peces_criterios, :source => :pez

  belongs_to :propiedad

  scope :join_propiedades,  -> { joins('LEFT JOIN propiedades ON propiedades.id=criterios.propiedad_id') }
  #scope :grupos_conabio, -> { where(nombre_propiedad: 'Grupo CONABIO').first.children.order(:nombre_propiedad) }
  #scope :zonas, -> { where(nombre_propiedad: 'Zonas').first.children }
  scope :tipo_capturas, -> { select('criterios.id, nombre_propiedad').join_propiedades.where("ancestry=?", 320) }
  scope :tipo_vedas, -> { where(nombre_propiedad: 'Tipo de veda').first.children }
  scope :procedencias, -> { where(nombre_propiedad: 'Procedencia').first.children }
  scope :pesquerias, -> { select(:nombre_propiedad).where(tipo_propiedad: 'Pesquerías en vías de sustentabilidad ').distinct.order(:nombre_propiedad) }
  scope :cnp, -> { select(:nombre_propiedad).where(tipo_propiedad: ['zona pacifico', 'zona golfo y caribe']).distinct.order(:nombre_propiedad) }
  scope :nom, -> { where(nombre_propiedad: 'Norma Oficial Mexicana 059 SEMARNAT-2010').first.children.order(:nombre_propiedad) }
  scope :iucn, -> { where(nombre_propiedad: 'Lista roja IUCN 2016-3').first.children.order(:nombre_propiedad) }

  def self.catalogo

    resp = Rails.cache.fetch('criterios_catalogo', expires_in: eval(CONFIG.cache.peces.catalogos)) do
      grouped_options = {}

      Criterio.select(:id, :propiedad_id).group(:propiedad_id).each do |c|
        prop = c.propiedad
        llave_unica = prop.ancestors.map(&:nombre_propiedad).join('/')

        grouped_options[llave_unica] = [] if !grouped_options.key?(llave_unica)
        grouped_options[llave_unica] << [prop.nombre_propiedad, c.id]
      end

      grouped_options
    end

    resp
  end

end