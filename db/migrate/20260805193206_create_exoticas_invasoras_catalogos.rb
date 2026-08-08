class CreateExoticasInvasorasCatalogos < ActiveRecord::Migration[5.1]
  def change
    create_table :exoticas_invasoras_catalogos do |t|
      t.integer :exotica_invasora_id, null: false
      t.integer :catalogo_id, null: false

      t.timestamps
    end

    add_index :exoticas_invasoras_catalogos,
              [:exotica_invasora_id, :catalogo_id],
              unique: true,
              name: "idx_exoticas_catalogos"

    add_index :exoticas_invasoras_catalogos, :catalogo_id
  end
end