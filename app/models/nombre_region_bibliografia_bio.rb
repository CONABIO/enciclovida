class NombreRegionBibliografiaBio < ActiveRecord::Base

  self.table_name='RelNomNomcomunRegionBiblio'
  self.primary_keys= :IdNombre, :IdRegion, :IdNomComun, :IdBibliografia

  attr_accessor :bibliografia_id_falsa
  belongs_to :especie
  belongs_to :region
  belongs_to :bibliografia
  belongs_to :nombre_comun
end
