class CategoriaContenidoRol < ActiveRecord::Base
  belongs_to :categoria_contenido
  belongs_to :rol

  scope :join_roles,-> { joins('JOIN roles on rol_id = roles.id') }
  scope :join_categorias_contenido,-> { joins('JOIN categorias_contenido on categoria_contenido_id = categorias_contenido.id') }
  scope :select_para_joins, -> { select("categoria_contenidos_roles.id, categoria_contenido_id, categorias_contenido.nombre, rol_id, roles.nombre_rol")} #TODO debe ser categoriaS_contenido no al reves
  scope :join_categorias_contenido_rol,-> { select_para_joins.join_roles.join_categorias_contenido }

end
