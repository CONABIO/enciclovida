class Anp < ActiveRecord::Base
  establish_connection(:snib)
  self.table_name = 'anpestat'
  self.primary_key = 'anpestid'

  scope :campos_min, -> { select('anpestid AS region_id, CONCAT(nombre, \', \', entidad) AS nombre_region').order(nombre: :asc) }
end