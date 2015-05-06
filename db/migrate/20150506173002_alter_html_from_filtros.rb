class AlterHtmlFromFiltros < ActiveRecord::Migration
  def change
    change_table(:filtros) do |t|
      t.change :html, :text, :null => true
    end
  end
end
