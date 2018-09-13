class AddAncestryToRoles < ActiveRecord::Migration[5.1]
  def change
    change_table(:roles) do |t|
      t.remove :atributos_base
      t.remove :tablas_adicionales
      t.remove :permisos
      t.remove :usuarios_especificos
      t.remove :es_admin
      t.remove :es_super_usuario
      t.remove :prioridad
      t.remove :taxonomia_especifica
      t.string :ancestry
      t.string :observaciones
    end
  end
end
