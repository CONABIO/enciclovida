class AddInstitucionToComentarios < ActiveRecord::Migration
  def change
    change_table(:comentarios) do |t|
      t.string :institucion
    end
  end
end
