class AlterUsuarios < ActiveRecord::Migration[5.1]
  def self.up
    change_table(:usuarios) do |t|
      ## Campos no necesarios de la gema devise

      remove_column :usuarios, :contrasenia
      remove_column :usuarios, :salt
      remove_column :usuarios, :correo
    end
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end

