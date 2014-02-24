class ChangeColumnFuenteEspecies < ActiveRecord::Migration
  def change
    change_column :especies, :fuente, :string, :null => true
  end
end
