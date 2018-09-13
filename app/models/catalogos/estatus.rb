class Estatus < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.Tipo_Relacion"
  self.primary_key = 'IdTipoRelacion'

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdTipoRelacion
  alias_attribute :descripcion, :Descripcion
  alias_attribute :nivel1, :Nivel1
  alias_attribute :nivel2, :Nivel2
  alias_attribute :nivel3, :Nivel3
  alias_attribute :nivel4, :Nivel4
  alias_attribute :nivel5, :Nivel5
  alias_attribute :ruta_icono, :RutaIcono

  scope :tiene_sinonimos?, -> { where(nivel1: 1, nivel2: 0, nivel3: 0, nivel4: 0, nivel5: 0).count }
  scope :tiene_homonimias?, -> { where(nivel1: 7, nivel2: 0, nivel3: 0, nivel4: 0, nivel5: 0).count }
end
