class EspecieBibliografiaBio < ActiveRecord::Base
  self.table_name='RelNombreBiblio'
  self.primary_keys= :IdNombre, :IdBibliografia

  belongs_to :especie
  belongs_to :bibliografia
end
