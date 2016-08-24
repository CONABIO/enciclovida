class CreateComentariosGenerales < ActiveRecord::Migration
  def change
    create_table :comentarios_generales, :id => false do |t|
      t.string :id, limit: 10, null: false, default: '', unique: true
      t.timestamps
    end
  end

  def down
    drop_table :comentarios_generales
  end
end
