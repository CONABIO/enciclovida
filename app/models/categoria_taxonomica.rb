class CategoriaTaxonomica < ActiveRecord::Base
  self.table_name = 'categorias_taxonomicas'
  self.primary_key = 'id'
  has_many :especies

  scope :cat_taxonom, ->(valor) { find(valor).nombre_categoria_taxonomica }

  def self.categorias_redis(tipo)
    categorias = all.map{|cat| "'#{tipo}_" << I18n.transliterate(cat.nombre_categoria_taxonomica).gsub(' ','_') << "'"}.uniq.join(',')
    "[#{categorias}]"
  end
end
