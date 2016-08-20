class AddAutoIncrementToBase32IdInComentarios < ActiveRecord::Migration
  def up
    add_column :comentarios, :idBak, :string
    Comentario.update_all('idBak=id')
    remove_column :comentarios, :id
    add_index :comentarios, :created_at, unique: true
    add_column :comentarios, :idConsecutivo, 'int NOT NULL IDENTITY (1,1) '
    add_column :comentarios, :id, :nvarchar, limit: 10, null: false, default: ''
    Comentario.update_all('id=dbo.ConvertToBase(idConsecutivo, 32)')  # Crear funcion o coorer script is_comentarios_a_base32
    execute "ALTER TABLE comentarios ADD PRIMARY KEY (id);"

    remove_index :comentarios, :created_at
  end

  def down
    remove_column :comentarios, :idConsecutivo
    Comentario.update_all('id=idBak')
    remove_column :comentarios, :idBak
  end
end
