class AddPathToMetadatos < ActiveRecord::Migration[5.1]
  def change
    change_table(:metadatos) do |t|
      ## Campo adicional para el SNIB
      t.text :path
    end
  end
end
