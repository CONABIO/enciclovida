class Criterio < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='criterios'

  has_many :peces_criterios, :class_name => 'PezCriterio', :foreign_key => :criterio_id
  has_many :peces, :through => :peces_criterios, :source => :pez

  belongs_to :propiedad

  scope :select_propiedades, -> { select('criterios.id, nombre_propiedad') }
  scope :join_propiedades, -> { joins('LEFT JOIN propiedades ON propiedades.id=criterios.propiedad_id') }
  scope :select_join_propiedades, -> { select_propiedades.join_propiedades }

  scope :tipo_capturas, -> { select_join_propiedades.where("ancestry=?", 320) }
  scope :tipo_vedas, -> { select_join_propiedades.where("ancestry=?", 321) }
  scope :procedencias, -> { select_join_propiedades.where("ancestry=?", 322) }
  scope :nom, -> { select_join_propiedades.where("ancestry=?", 318) }
  scope :iucn, -> { select_join_propiedades.where("ancestry=?", 319) }
  scope :cnp, -> { select_join_propiedades.where("ancestry REGEXP '323/31[123456]$'").where("tipo_propiedad != 'estado'") }

  def self.catalogo

    resp = Rails.cache.fetch('criterios_catalogo', expires_in: CONFIG.cache.peces.catalogos) do
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

  def self.pesquerias
    grouped_options = {}

    Criterio.select_propiedades.select('propiedad_id').join_propiedades.where('tipo_propiedad=?', 'Pesquerías en vías de sustentabilidad').each do |c|
      prop = c.propiedad
      llave_unica = prop.parent.nombre_propiedad.strip

      grouped_options[llave_unica] = [] if !grouped_options.key?(llave_unica)
      grouped_options[llave_unica] << [prop.nombre_propiedad, c.id]
    end

    grouped_options
  end

  def self.cnp_select
    cnp_options = ['Con potencial de desarrollo', 'Máximo aprovechamiento permisible', 'En deterioro']
    options = []

    cnp_options.each do |c|
      criterios = self.cnp.where('nombre_propiedad=?', c).map(&:id).join(',')
      options << [c, criterios]
    end

    options
  end

  def self.dame_filtros

    filtros = Rails.cache.fetch('filtros_peces', expires_in: CONFIG.cache.peces.filtros) do
      {grupos: Propiedad.grupos_conabio,
       zonas: Propiedad.zonas,
       tipo_capturas: self.tipo_capturas,
       tipo_vedas: self.tipo_vedas,
       procedencias: self.procedencias,
       pesquerias:  self.pesquerias,
       cnp: self.cnp_select,
       nom: self.nom,
       iucn: self.iucn}
    end

    filtros
  end

end