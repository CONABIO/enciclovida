class AddAncestryObligatorioToEspecie < ActiveRecord::Migration
  def change
    add_column :especies, :ancestry_acendente_obligatorio, :string
    add_index :especies, :ancestry_acendente_obligatorio
  end
end
