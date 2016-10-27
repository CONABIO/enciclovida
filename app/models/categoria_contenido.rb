class CategoriaContenido < ActiveRecord::Base
  self.table_name='categorias_contenido'

  has_ancestry

  has_many :categoria_contenido_rol, :class_name=> 'CategoriaContenidoRol', :foreign_key => :categoria_contenido_id

  REGISTROS_GEODATA = %w(6 7)  # De momento puede haber comentarios asociados a un ID para el snib y naturalista

  def self.grouped_options(con_comentario_general=false)
    con_cc = con_comentario_general ? 'categorias_comentario_grouped_options_con_cc' : 'categorias_comentario_grouped_options_sin_cc'

    if Rails.env.production?
      # Aplicando un low level caching, esta consulta es requerida simpre y casi nunca cambia
      Rails.cache.fetch(con_cc, expires_in: 12.hours) do
        self.categorias(con_comentario_general)
      end
    else
      self.categorias(con_comentario_general)
    end
  end

  def categoria_ancestro
    if is_root?
      nombre
    else
      path.map(&:nombre)
    end
  end

  # Regresa las categorias en un arreglo bidimensional para el grouped options
  def self.categorias(con_comentario_general)
    options = []

    CategoriaContenido.all.each do |cc|
      if con_comentario_general
        next if !cc.is_root? || cc.id == 28  # Para no poder escoger un tipo de comentario general
      else
        next unless cc.is_root?
      end

      grouped_options = []
      # Disabled a subir un mapa de distribucion
      descendientes = cc.descendants.map {|d| d.id == 8 ? [d.nombre, d.id, {disabled: 'disabled'}] : [d.nombre, d.id]}
      grouped_options << cc.nombre
      grouped_options << descendientes if descendientes.any?
      puts grouped_options.inspect
      options << grouped_options
    end

    options
  end
end
