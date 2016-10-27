class CategoriaContenidoRol < ActiveRecord::Base
  belongs_to :categoria_contenido
  belongs_to :rol
end
