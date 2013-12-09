class AddSaltToUsuario < ActiveRecord::Migration
  def change
    add_column :usuarios, :salt, :string
  end
end
