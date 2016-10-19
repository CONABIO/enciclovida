class NotNullOnCategoriaComentarioToComentarios < ActiveRecord::Migration
  def change
    change_table(:comentarios) do |t|
      # El default ya no deberia cambiar
      t.change :categoria_comentario_id, :string, :null => false, default: 30
    end
  end
end
