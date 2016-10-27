module UsuariosHelper
  def gradoYnombre(usuario)
    "#{usuario.nombre} #{usuario.apellido}"
  end
end
