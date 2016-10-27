class TruncateAndPopulateRoles < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE roles")

    Rol.create!([{nombre_rol:'Super usuario', taxonomia_especifica:nil, ancestry:nil, observaciones:'Todo poderoso'},
                {nombre_rol:'Administrador', taxonomia_especifica:nil, ancestry:'1', observaciones:''},
                {nombre_rol:'Curador', taxonomia_especifica:nil, ancestry:'1/2', observaciones:''},
                {nombre_rol:'AdministradorComentarios', taxonomia_especifica:8002491, ancestry:'1/2', observaciones:'Tiburones y rayas'}])
  end
end
