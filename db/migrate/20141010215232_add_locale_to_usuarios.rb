class AddLocaleToUsuarios < ActiveRecord::Migration
  def change
    add_column :usuarios, :locale, :string, :default => 'es', :null => false
  end
end
