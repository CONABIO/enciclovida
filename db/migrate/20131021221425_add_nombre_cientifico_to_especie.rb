class AddNombreCientificoToEspecie < ActiveRecord::Migration
  def change
    add_column :especies, :nombre_cientifico, :string
    add_index :especies, :nombre_cientifico
  end
end
