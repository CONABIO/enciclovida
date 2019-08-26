class EspecieRegion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.RelNombreRegion"
  self.primary_keys= :IdNombre, :IdRegion

  # Los alias con las tablas de catalogos
  alias_attribute :especie_id, :IdNombre
  alias_attribute :region_id, :IdRegion
  alias_attribute :observaciones, :Observaciones

  attr_accessor :region_id_falso
  validates_presence_of :especie_id, :region_id

  belongs_to :region, :foreign_key => Region.attribute_alias(:id)
  belongs_to :especie
  belongs_to :tipo_distribucion, -> { I18n.locale == 'es-cientifico' ? distribuciones_vista_especialistas : distribuciones_vista_general }, foreign_key: TipoDistribucion.attribute_alias(:id)
  has_many :nombres_regiones, :class_name => 'NombreRegion', :foreign_key => 'especie_id', :dependent => :destroy

end
