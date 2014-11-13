class AddPathToMetadatos < ActiveRecord::Migration
  def change
    change_table(:metadatos) do |t|
      ## Campo adicional para el SNIB
      t.text :path
    end

    add_index :metadatos, :path, :unique => true
  end
end
