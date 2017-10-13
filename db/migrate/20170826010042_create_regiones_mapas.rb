class CreateRegionesMapas < ActiveRecord::Migration
  def up
    create_table :regiones_mapas do |t|
      t.string :nombre_region
      t.integer :geo_id
      t.string :ancestry
      t.string :tipo_region
      t.timestamps
    end
  end

  def down
    drop_table :regiones_mapas
  end
end
