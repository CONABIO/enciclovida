class TipoDistribucion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.TipoDistribucion"
  self.primary_key = 'IdTipoDistribucion'

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdTipoDistribucion
  alias_attribute :descripcion, :Descripcion

  has_many :especies_regiones

  scope :distribuciones_vista_general, -> { where(descripcion: DISTRIBUCIONES_VISTA_GENERAL) }

  DISTRIBUCIONES_VISTA_GENERAL = %w(Endémica Nativa Exótica Exótica-Invasora)

  # REVISADO: Los tipos de distribucion de acuerdo a la vista y tambien en el show de especies en la simbologia de ayuda
  def self.distribuciones(vista_especialistas = true)
    if vista_especialistas
      all
    else
      d = distribuciones_vista_general
      [d[0], d[2], d[3], d[1]]  # Acomodo sugerido de cgalindo
    end
  end

end
