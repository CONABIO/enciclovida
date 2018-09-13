class TruncateAndPopulateRoles < ActiveRecord::Migration[5.1]
  def change
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE roles")

    Rol.create!([{nombre_rol:'Super usuario', ancestry:nil, observaciones:'Todo poderoso'},
                {nombre_rol:'Administrador', ancestry:'1', observaciones:''},
                {nombre_rol:'AdminComentarios', ancestry:'1/2', observaciones:''},
                {nombre_rol:'AdminComentariosSCAT', ancestry:'1/2/3', observaciones:''}
                ])
  end
end
