class AddSessionsTable < ActiveRecord::Migration
  def change
    create_table :sessiones do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :sessiones, :session_id, :unique => true
    add_index :sessiones, :updated_at
  end
end
