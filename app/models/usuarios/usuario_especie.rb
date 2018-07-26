class UsuarioEspecie < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  belongs_to :usuario
  belongs_to :especie

  scope :join_usuarios,-> { joins('JOIN usuarios on usuario_id = usuarios.id') }
  scope :join_especies,-> { joins('JOIN especies on especie_id = especies.id') }
  scope :select_para_joins, -> { select("usuarios_especie.id, usuario_id, usuarios.nombre, usuarios.apellido, usuarios.email, usuarios.institucion, especie_id, especies.nombre_cientifico")}
  scope :join_user_especies,-> { select_para_joins.join_usuarios.join_especies }

end
