class AddAutoIncrementToBase32IdInComentarios < ActiveRecord::Migration[5.1]
  def up
    change_table(:comentarios) do |t|
      t.remove :id
      t.integer :idConsecutivo
      t.string :id, :limit => 10, :primary_key => true
    end
  end

  def down
    change_table(:comentarios) do |t|
      t.remove :idConsecutivo
    end
  end
end
