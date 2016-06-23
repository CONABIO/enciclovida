class AddCategoriaComentarioIdToComentarios < ActiveRecord::Migration
  def change
    change_table(:comentarios) do |t|
      t.remove :especie_comentario_id
      t.integer :categoria_comentario_id
    end
  end
end
