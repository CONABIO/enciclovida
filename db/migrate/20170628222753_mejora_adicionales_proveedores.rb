class MejoraAdicionalesProveedores < ActiveRecord::Migration[5.1]
  def change
    change_table(:adicionales) do |t|
      t.remove :justificacion_nombre
      t.remove :justificacion_foto
      t.remove :icono_id
      t.remove :fotos_principales
    end

    change_table(:proveedores) do |t|
      t.remove :naturalista_info
      t.remove :naturalista_obs
      t.remove :snib_id
      t.remove :snib_reino
    end
  end

end
