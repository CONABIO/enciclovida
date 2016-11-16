class Rol < ActiveRecord::Base

  has_ancestry

  has_many :roles_categorias_contenidos, :class_name=> 'RolCategoriasContenido', :foreign_key => :rol_id
  has_many :roles, :through => :roles_categorias_contenidos

end