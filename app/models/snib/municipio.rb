class Estado < ActiveRecord::Base
  establish_connection(:snib)

  scope :campos_min, -> { select(:cve_ent, :cve_mun, :municipio).order(municipio: :asc) }
end