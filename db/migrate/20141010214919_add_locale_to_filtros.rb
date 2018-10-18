class AddLocaleToFiltros < ActiveRecord::Migration[5.1]
  def change
    add_column :filtros, :locale, :string, :default => 'es', :null => false
  end
end
