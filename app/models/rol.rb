class Rol < ActiveRecord::Base

  has_ancestry

  has_many :categoria_contenido_rol, :class_name=> 'CategoriaContenidoRol', :foreign_key => :rol_id

end