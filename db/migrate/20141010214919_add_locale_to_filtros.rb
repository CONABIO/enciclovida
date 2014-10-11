class AddLocaleToFiltros < ActiveRecord::Migration
  def change
    add_column :filtros, :locale, :string, :default => 'es', :null => false
  end
end
