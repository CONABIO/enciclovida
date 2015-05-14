class CreateIconos < ActiveRecord::Migration
  def change
    create_table :iconos do |t|
      t.string :taxon_icono, :null => false
      t.string :icono, :null => false
      t.string :nombre_icono, :null => false
      t.string :color_icono, :null => false
      t.text :observaciones
      t.timestamps
    end
  end
end
