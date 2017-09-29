class Rol < ActiveRecord::Base

  has_ancestry

  has_many :roles_categorias_contenidos, :class_name=> 'RolCategoriasContenido', :foreign_key => :rol_id
  has_many :categorias_contenidos, :through => :roles_categorias_contenidos, :source => :categorias_contenido

  has_many :usuario_roles, :class_name => 'UsuarioRol', :foreign_key => :rol_id
  has_many :usuarios, :through => :usuario_roles, :source => :usuario

end