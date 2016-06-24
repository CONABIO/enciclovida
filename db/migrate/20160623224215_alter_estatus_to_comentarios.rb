class AlterEstatusToComentarios < ActiveRecord::Migration
  def change
    change_table(:comentarios) do |t|
      t.change :categoria_comentario_id, :integer, null: false, default: 26
      t.change :estatus, :integer, default: 1, null: false
    end
  end
end
