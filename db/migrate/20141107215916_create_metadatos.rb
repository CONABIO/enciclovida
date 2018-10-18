class CreateMetadatos < ActiveRecord::Migration[5.1]
  def change
    create_table :metadatos do |t|
      t.string :object_name
      t.string :artist
      t.string :copyright
      t.string :country_name
      t.string :province_state
      t.string :transmission_reference
      t.string :category
      t.string :supp_category
      t.string :keywords
      t.text :custom_field12
      t.string :custom_field6
      t.string :custom_field7
      t.string :custom_field13
      t.timestamps
    end
  end
end
