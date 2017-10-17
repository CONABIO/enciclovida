class Estado < ActiveRecord::Base
  establish_connection(:snib)
  self.primary_key = 'entid'

  scope :campos_min, -> { select('entid AS region_id, entidad AS nombre_region').order(entidad: :asc) }
end