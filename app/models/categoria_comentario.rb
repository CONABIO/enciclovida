class CategoriaComentario < ActiveRecord::Base
  self.table_name='categorias_comentario'

  has_ancestry

  def self.grouped_options(con_comentario_general=false)
    # Aplicando un low level caching, esta consulta es requerida simpre y casi nunca cambia
    if con_comentario_general
      Rails.cache.fetch('categorias_comentario_grouped_options_con_cc', expires_in: 12.hours) do

        options = []

        CategoriaComentario.all.each do |cc|
          next if !cc.is_root? || (cc.id == 28 && con_comentario_general)  # Para no poder escoger un tipo de comentario general
          grouped_options = []

          descendientes = cc.descendants.map {|d| [d.nombre, d.id]}
          grouped_options << cc.nombre
          grouped_options << descendientes if descendientes.any?

          options << grouped_options
        end

        options
      end
    else

      Rails.cache.fetch('categorias_comentario_grouped_options_sin_cc', expires_in: 12.hours) do

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
    end
  end

  def categoria_ancestro
    if is_root?
      nombre
    else
      path.map(&:nombre)
    end
  end
end
