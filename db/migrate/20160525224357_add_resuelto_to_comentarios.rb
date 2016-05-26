class AddResueltoToComentarios < ActiveRecord::Migration
  def change
    change_table(:comentarios) do |t|
      t.integer :resuelto, :null => false, :default => 0
    end
  end
end
