class AddNombresComunesToAdicionales < ActiveRecord::Migration
  def change
    change_table(:adicionales) do |t|
      t.text :nombres_comunes
    end
  end
end
