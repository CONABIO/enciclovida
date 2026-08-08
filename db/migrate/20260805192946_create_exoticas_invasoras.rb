class CreateExoticasInvasoras < ActiveRecord::Migration[5.1]
  def change
    create_table :exoticas_invasoras do |t|
      t.integer :especie_id, null: false

      t.integer :grupo_id
      t.integer :ambiente_id
      t.integer :origen_id
      t.integer :presencia_id
      t.integer :estatus_id

      t.string :creditos_fotos
      t.text :observaciones

      t.timestamps
    end

    add_index :exoticas_invasoras, :especie_id, unique: true

    add_index :exoticas_invasoras, :grupo_id
    add_index :exoticas_invasoras, :ambiente_id
    add_index :exoticas_invasoras, :origen_id
    add_index :exoticas_invasoras, :presencia_id
    add_index :exoticas_invasoras, :estatus_id
  end
end