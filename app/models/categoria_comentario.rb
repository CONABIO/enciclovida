class CategoriaComentario < ActiveRecord::Base
  self.table_name='categorias_comentario'

  has_ancestry

  def self.grouped_options
    options = []

    CategoriaComentario.all.each do |cc|
      next unless cc.is_root?
      grouped_options = []

      descendientes = cc.descendants.map {|d| [d.nombre, d.id]}
      grouped_options << cc.nombre
      grouped_options << descendientes if descendientes.any?

      options << grouped_options
    end

    options
  end

  def categoria_ancestro
    if is_root?
      nombre
    else
      path.map(&:nombre)
    end
  end
end
