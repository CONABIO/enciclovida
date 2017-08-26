class CreateRegionesMapas < ActiveRecord::Migration
  def change
    create_table :regiones_mapas do |t|

      t.timestamps
    end
  end
end
