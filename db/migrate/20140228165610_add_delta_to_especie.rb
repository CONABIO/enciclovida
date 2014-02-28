class AddDeltaToEspecie < ActiveRecord::Migration
  def change
    add_column :especies, :delta, :boolean, :default => false
  end
end
