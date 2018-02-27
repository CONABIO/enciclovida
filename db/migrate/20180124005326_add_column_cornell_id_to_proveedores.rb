class AddColumnCornellIdToProveedores < ActiveRecord::Migration[5.1]

  def up
    change_table(:proveedores) do |t|
      t.text :cornell_id
    end
  end

  def down
    change_table(:proveedores) do |t|
      t.remove :cornell_id
    end
  end

end
