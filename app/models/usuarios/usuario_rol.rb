class UsuarioRol < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  belongs_to :usuario
  belongs_to :rol

  scope :join_roles,-> { joins('JOIN roles on rol_id = roles.id') }
  scope :join_usuarios,-> { joins('JOIN usuarios on usuario_id = usuarios.id') }
  scope :select_para_joins, -> { select("usuarios_roles.id, usuario_id, usuarios.nombre, usuarios.apellido, usuarios.email, usuarios.institucion, rol_id, roles.nombre_rol")}
  scope :join_user_rol,-> { select_para_joins.join_roles.join_usuarios }

end
