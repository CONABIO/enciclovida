class AddNombresComunesToAdicionales < ActiveRecord::Migration[5.1]
  def change
    change_table(:adicionales) do |t|
      t.text :nombres_comunes
    end
  end
end
