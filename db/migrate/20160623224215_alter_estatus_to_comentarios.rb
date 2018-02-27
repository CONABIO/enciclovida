class AlterEstatusToComentarios < ActiveRecord::Migration[5.1]
  def change
    change_table(:comentarios) do |t|
      t.change :categoria_comentario_id, :integer, null: false, default: 31
      t.change :estatus, :integer, default: 1, null: false
    end
  end
end
