class AddAncestryToEspecie < ActiveRecord::Migration
  def change
    add_column :especies, :ancestry_acendente_directo, :string
    add_index :especies, :ancestry_acendente_directo
  end
end
