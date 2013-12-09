module UsuariosHelper
  def gradoYnombre(usuario)
    "#{usuario.grado_academico} #{usuario.nombre} #{usuario.apellido}"
  end
end
