class UsuarioEspecie < ActiveRecord::Base
  belongs_to :usuario
  belongs_to :especie
end
