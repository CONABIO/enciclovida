class AddAncestryToRegiones < ActiveRecord::Migration
  def change
    add_column :regiones, :ancestry, :string
    add_index :regiones, :ancestry
  end
end
