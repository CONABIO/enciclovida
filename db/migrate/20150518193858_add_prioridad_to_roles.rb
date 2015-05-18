class AddPrioridadToRoles < ActiveRecord::Migration
  def change
    change_table(:roles) do |t|
      t.integer :prioridad, :null => false, :default => 0
    end
  end
end
