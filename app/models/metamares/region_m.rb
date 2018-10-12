class Metamares::RegionM < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.metamares}.regiones"

  REGIONES = ['B. Camp. Caribe'.to_sym, 'Central Pacific'.to_sym, 'Freshwater/Terrestrial'.to_sym,
              'G. California'.to_sym, 'South Pacific'.to_sym, 'W. G. Mexico'.to_sym]

end