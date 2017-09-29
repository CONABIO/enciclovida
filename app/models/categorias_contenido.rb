class CategoriasContenido < ActiveRecord::Base
  self.table_name='categorias_contenido'

  has_ancestry

  has_many :roles_categorias_contenidos, :class_name=> 'RolCategoriasContenido', :foreign_key => :categorias_contenido_id
  has_many :roles, :through => :roles_categorias_contenidos, :source => :rol
  has_many :usuarios, :through => :roles, :source => :usuarios

  REGISTROS_SNIB = [6, 32, 33, 34]
  REGISTROS_NATURALISTA = [7]
  REGISTROS_GEODATA = [REGISTROS_SNIB, REGISTROS_NATURALISTA].flatten  # De momento puede haber comentarios asociados a un ID para el snib y naturalista
  MAPA_DISTRIBUCION = 9
  COMENTARIO_GENERAL = 28
  COMENTARIO_ENCICLOVIDA = 29

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

    CategoriasContenido.all.each do |cc|
      if con_comentario_general
        next if !cc.is_root? || cc.id == COMENTARIO_GENERAL  # Para no poder escoger un tipo de comentario general
      else
        next unless cc.is_root?
      end

      grouped_options = []

      cc.children.each do |d|
        if d.id == MAPA_DISTRIBUCION
          grouped_options << [d.nombre, d.id, {disabled: 'disabled'}]
        else

          if d.children.count > 0
            grouped_options << [d.nombre, d.id]
            d.children.each { |dd| grouped_options << [dd.nombre, dd.id]}
          else
            grouped_options << [d.nombre, d.id]
          end
        end  # End aportar mapa distribucion
      end

      if grouped_options.any?
        options << [cc.nombre, grouped_options]
      end

    end

    options
  end

  # Regresa las categorias en un arreglo bidimensional para el grouped options
  def self.categorias_para_roles
    grouped_options = []

    CategoriasContenido.all.each do |cc|
      next unless cc.is_root?
      grouped_options << [cc.nombre, cc.id]

      cc.children.each do |d|
        if d.children.count > 0
          grouped_options << [d.nombre, d.id]
          d.children.each { |dd| grouped_options << [dd.nombre, dd.id]}
        else
          grouped_options << [d.nombre, d.id]
        end
      end

    end

    grouped_options
  end
end
