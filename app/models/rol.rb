class Rol < ActiveRecord::Base
  # Los roles para poder consultar la variable
  ROLES =
      {
          1 => 'DEFAULT',
          4 => 'CURADOR_BASICO',
          2 => 'ADMIN',
          3 => 'SUPER_USUARIO'
      }

  # Roles que pueden hacer CRUD con listas
  DEFAULT = [1]

  #Roles que pueden editar la foto y el nombre comun principal
  CURADOR_BASICO = [4]
  CURADOR_BASICO << DEFAULT
  CURADOR_BASICO = CURADOR_BASICO.flatten.compact.uniq

  # Roles que pueden editar toda la taxonomia
  ADMIN = [2]
  ADMIN << DEFAULT << CURADOR_BASICO
  ADMIN = ADMIN.flatten.compact.uniq

  # Roles que pueden editar todo
  SUPER_USUARIO = [3]
  SUPER_USUARIO << ADMIN
  SUPER_USUARIO = SUPER_USUARIO.flatten.compact.uniq

  # Roles que pueden ver las bitacoras
  CON_BITACORA = []
  CON_BITACORA << ADMIN << SUPER_USUARIO
  CON_BITACORA = CON_BITACORA.flatten.compact.uniq
end