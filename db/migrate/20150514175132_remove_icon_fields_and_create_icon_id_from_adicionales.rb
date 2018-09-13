class RemoveIconFieldsAndCreateIconIdFromAdicionales < ActiveRecord::Migration[5.1]
  def change
    change_table(:adicionales) do |t|
      t.remove :icono
      t.remove :nombre_icono
      t.remove :color_icono
      t.integer :icono_id
    end
  end
end
