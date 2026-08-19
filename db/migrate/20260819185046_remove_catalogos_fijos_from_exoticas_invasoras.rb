class RemoveCatalogosFijosFromExoticasInvasoras < ActiveRecord::Migration[5.1]
  def change
    remove_column :exoticas_invasoras, :grupo_id, :integer
    remove_column :exoticas_invasoras, :ambiente_id, :integer
    remove_column :exoticas_invasoras, :origen_id, :integer
    remove_column :exoticas_invasoras, :presencia_id, :integer
    remove_column :exoticas_invasoras, :estatus_id, :integer
  end
end