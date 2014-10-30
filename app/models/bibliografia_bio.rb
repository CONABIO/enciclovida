class BibliografiaBio < ActiveRecord::Base

  self.table_name='Bibliografia'
  self.primary_key='IdBibliografia'

  has_many :nombres_regiones_bibligrafias
  has_many :especies_bibliografias
end
