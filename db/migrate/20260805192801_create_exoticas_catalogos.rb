class CreateExoticasCatalogos < ActiveRecord::Migration[5.1]
  def change
    create_table :exoticas_catalogos do |t|
      t.string :tipo, null: false
      t.string :clave, null: false
      t.string :nombre, null: false
      t.text :descripcion

      t.boolean :activo, default: true
      t.integer :orden, default: 0

      t.timestamps
    end

    add_index :exoticas_catalogos, :tipo
    add_index :exoticas_catalogos, [:tipo, :clave], unique: true
  end
end
