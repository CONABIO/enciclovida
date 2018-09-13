class AlterComentarios < ActiveRecord::Migration[5.1]
  def change
    change_table(:comentarios) do |t|
      t.rename :resuelto, :estatus
      t.string :ancestry
      t.integer :especie_comentario_id
      t.datetime :fecha_estatus
      t.integer :usuario_id2
    end
  end
end
