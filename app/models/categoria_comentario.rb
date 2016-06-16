class CategoriaComentario < ActiveRecord::Base
  self.table_name='categorias_comentario'

  has_ancestry

  def self.grouped_options
    options = []

    CategoriaComentario.all.each do |cc|
      next unless cc.is_root?
      nested_options = []

      descendientes = cc.descendants.map(&:nombre)
      nested_options << cc.nombre
      nested_options << descendientes if descendientes.any?

      options << nested_options
    end

    options
  end
end
