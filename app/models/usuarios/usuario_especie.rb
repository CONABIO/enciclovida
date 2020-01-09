class UsuarioEspecie < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.usuarios_especie"

  belongs_to :usuario
  belongs_to :especie, :class_name=> 'Especie'

  scope :join_usuarios,-> { joins('JOIN enciclovida.usuarios on usuario_id = usuarios.id') }
  scope :join_especies,-> { joins("JOIN #{Especie.table_name} on especie_id = #{Especie.attribute_alias(:id)}") }
  scope :select_para_joins, -> { select("usuarios_especie.id, usuario_id, usuarios.nombre, usuarios.apellido, usuarios.email, usuarios.institucion, especie_id, #{Especie.attribute_alias(:nombre_cientifico)}")}
  scope :join_user_especies,-> { select_para_joins.join_usuarios.join_especies }

end
