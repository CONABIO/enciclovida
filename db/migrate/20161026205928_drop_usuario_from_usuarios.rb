class DropUsuarioFromUsuarios < ActiveRecord::Migration[5.1]
  def change
    change_table(:usuarios) do |t|
      t.remove :usuario
      t.remove :grado_academico
      t.change :institucion, :string, null: true
      t.string :observaciones
    end
  end
end
