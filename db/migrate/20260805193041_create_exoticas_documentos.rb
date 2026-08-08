class CreateExoticasDocumentos < ActiveRecord::Migration[5.1]
  def change
    create_table :exoticas_documentos do |t|
      t.integer :exotica_invasora_id, null: false

      t.integer :tipo_documento_id, null: false

      t.string :titulo, null: false

      t.string :rutabund, null: false

      t.string :nombre_original

      t.text :descripcion

      t.timestamps
    end

    add_index :exoticas_documentos, :exotica_invasora_id
    add_index :exoticas_documentos, :tipo_documento_id
  end
end