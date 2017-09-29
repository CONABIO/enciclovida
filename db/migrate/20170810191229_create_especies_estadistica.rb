class CreateEspeciesEstadistica < ActiveRecord::Migration
  def up
    create_table :especies_estadistica do |t|
      t.integer :especie_id
      t.integer :estadistica_id
      t.integer :conteo

      t.timestamps
    end
  end

  def down
    drop_table :especies_estadistica
  end
end
