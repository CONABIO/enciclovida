class CreateValidaciones < ActiveRecord::Migration[5.1]
  def change
    create_table :validaciones do |t|
      t.integer :usuario_id, :null => false
      t.string :nombre_archivo, null: false
      t.integer :enviado, limit: 1, default: 0, null: false
      t.datetime :fecha_envio
      t.timestamps
    end
  end
end
