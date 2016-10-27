class TruncateAndPopulateRoles < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE roles")

    Rol.create!([{nombre_rol:'Super usuario', ancestry:nil, observaciones:'Todo poderoso'},
                {nombre_rol:'Administrador', ancestry:'1', observaciones:''},
                {nombre_rol:'Fotos', ancestry:'1/2', observaciones:''},
                {nombre_rol:'Mapas', ancestry:'1/2', observaciones:''},
                {nombre_rol:'Fichas', ancestry:'1/2', observaciones:''},
                {nombre_rol:'NombresComunes', ancestry:'1/2', observaciones:''},
                {nombre_rol:'Taxonomia', ancestry:'1/2', observaciones:''},
                ])
  end
end
