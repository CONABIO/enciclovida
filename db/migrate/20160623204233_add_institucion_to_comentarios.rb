class AddInstitucionToComentarios < ActiveRecord::Migration[5.1]
  def change
    change_table(:comentarios) do |t|
      t.string :institucion
    end
  end
end
