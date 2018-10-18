class AlterPhotosNativeUrlToMax < ActiveRecord::Migration[5.1]
  def up
    change_column :photos, :native_page_url, :text
  end

  def down
    change_column :photos, :native_page_url, :string, :limit => 255
  end
end
