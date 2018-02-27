class RemoveRolIdFromUsuario < ActiveRecord::Migration[5.1]
  def change
    change_table(:usuarios) do |t|
      t.remove :rol_id
    end
  end
end
