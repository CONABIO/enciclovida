class AddLocaleToUsuarios < ActiveRecord::Migration[5.1]
  def change
    add_column :usuarios, :locale, :string, :default => 'es', :null => false
  end
end
