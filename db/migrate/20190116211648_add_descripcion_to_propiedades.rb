class AddDescripcionToPropiedades < ActiveRecord::Migration[5.1]
  def up
    add_column "#{CONFIG.bases.pez}.propiedades", :descripcion, :text
  end

  def down
    remove_column "#{CONFIG.bases.pez}.propiedades", :descripcion
  end
end
