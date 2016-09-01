class CreateComentariosGenerales < ActiveRecord::Migration
  def change
    create_table :comentarios_generales do |t|
      t.string :comentario_id, limit: 10, null: false, default: '', unique: true
      t.timestamps
    end
  end

  def down
    drop_table :comentarios_generales
  end
end
