class Metamares::RegionM < MetamaresAbs

  self.table_name = "#{CONFIG.bases.metamares}.regiones"

  REGIONES = ['G California'.to_sym, 'Central Pacific'.to_sym, 'South Pacific'.to_sym, 'W G Mexico'.to_sym, 'B Camp Caribe'.to_sym, 'Freshwater_Terrestrial'.to_sym]
  ZONAS = ['Atlantic'.to_sym, 'Freshwater/Terrestrial'.to_sym, 'National'.to_sym, 'Pacific'.to_sym]
end