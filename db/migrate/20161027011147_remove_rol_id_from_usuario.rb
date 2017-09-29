class RemoveRolIdFromUsuario < ActiveRecord::Migration
  def change
    change_table(:usuarios) do |t|
      t.remove :rol_id
    end
  end
end
