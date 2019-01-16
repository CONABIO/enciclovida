class AddDescripcionToPropiedades < ActiveRecord::Migration[5.1]
  def conexion_a_pmc
    @connection = ActiveRecord::Base.establish_connection(CONFIG.bases.pez.to_sym).connection
  end

  def up
    add_column "#{CONFIG.bases.pez}.propiedades", :descripcion, :text
  end

  def down
    remove_column "#{CONFIG.bases.pez}.propiedades", :descripcion
  end
end
