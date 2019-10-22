class TipoDistribucion < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.TipoDistribucion"
  self.primary_key = 'IdTipoDistribucion'

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdTipoDistribucion
  alias_attribute :descripcion, :Descripcion

  has_many :especies_regiones

  scope :distribuciones_vista_general, -> { where(descripcion: DISTRIBUCIONES_VISTA_GENERAL) }
  scope :distribuciones_vista_especialistas, -> { where(descripcion: DISTRIBUCIONES_VISTA_ESPECIALISTAS) }

  DISTRIBUCIONES_VISTA_GENERAL = %w(Endémica Nativa Exótica Exótica-Invasora)
  DISTRIBUCIONES_VISTA_ESPECIALISTAS = DISTRIBUCIONES_VISTA_GENERAL + %w(Cuasiendémica Semiendémica)

  # REVISADO: Los tipos de distribucion de acuerdo a la vista y tambien en el show de especies en la simbologia de ayuda
  def self.distribuciones(vista_especialistas = true)
    distribuciones = []

    if vista_especialistas
      distribuciones_vista_especialistas.each do |d|
        distribuciones[DISTRIBUCIONES_VISTA_ESPECIALISTAS.index(d.descripcion)] = d
      end
    else
      distribuciones_vista_general.each do |d|
        distribuciones[DISTRIBUCIONES_VISTA_GENERAL.index(d.descripcion)] = d
      end
    end

    distribuciones
  end

end
