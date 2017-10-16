class Estado < ActiveRecord::Base
  establish_connection(:snib)

  scope :campos_min, -> { select(:entid, :entidad).order(entidad: :asc) }
end