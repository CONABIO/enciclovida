class NotNullOnCategoriaComentarioToComentarios < ActiveRecord::Migration
  def change
    change_table(:comentarios) do |t|
      t.change :categoria_comentario_id, :string, :null => false, default: 26
    end
  end
end
