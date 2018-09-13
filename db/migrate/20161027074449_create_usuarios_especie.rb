class CreateUsuariosEspecie < ActiveRecord::Migration[5.1]
  def change
    create_table :usuarios_especie do |t|
      t.integer :usuario_id
      t.integer :especie_id

      t.timestamps
    end
  end
end
