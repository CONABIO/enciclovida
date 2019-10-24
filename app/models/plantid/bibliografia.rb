class Plantid::Bibliografia < Plantidabs
  self.table_name = "#{CONFIG.bases.plantid}.bibliografias"

  belongs_to :plantas
end