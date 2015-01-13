class CreateMetadatoEspecies < ActiveRecord::Migration
  def change
    create_table :metadato_especies, :force => true do |t|
      t.integer 'especie_id', null: false
      t.integer 'metadato_id', null: false
      t.timestamps
    end
  end
end
