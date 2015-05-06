class CreateAdicionales < ActiveRecord::Migration
  def change
    create_table :adicionales do |t|
      t.integer :especie_id, :null => false
      t.string :nombre_comun_principal
      t.text :justificacion_nombre
      t.string :foto_principal
      t.text :justificacion_foto
      t.string :icono
      t.string :nombre_icono
      t.string :color_icono
      t.timestamps
    end
  end
end
