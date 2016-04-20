class CreateCategoriasConteo < ActiveRecord::Migration
  def change
    create_table :categorias_conteo do |t|
      t.integer :especie_id, :null => false
      t.integer :conteo, :null => false
      t.column :categoria, 'char(4)', :null => false
      t.timestamps
    end
  end
end