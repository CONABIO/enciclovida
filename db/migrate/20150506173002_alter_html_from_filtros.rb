class AlterHtmlFromFiltros < ActiveRecord::Migration[5.1]
  def change
    change_table(:filtros) do |t|
      t.change :html, :text, :null => true
    end
  end
end
