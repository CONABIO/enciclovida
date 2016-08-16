class AddAutoIncrementToBase32IdInComentarios < ActiveRecord::Migration
=begin
#Esta forma de escribir la migración funcionaría siu se divide en 3 migraciones para poder acceder libremente al modelo sin que haya lock
  def up
    change_table :comentarios2 do |t|
      t.column :idBak, :string
      Comentario2.update_all('idBak=id')
      t.remove :id
      t.index :created_at, unique: true
      t.column :id, 'int NOT NULL IDENTITY (1,1) '
      t.column :idBase32, :nvarchar, limit: 10, null: false, default: 'zzz'
    end
    Comentario2.all.each do |c|
      c.idBase32 = c.id.to_s(32)
      c.save
    end
    #rename_column :comentarios2, :id, :idConsecutivo
    #rename_column :comentarios2, :idBase32, :id
    #execute "ALTER TABLE comentarios2 ADD PRIMARY KEY (id);"
    end
=end

  def up
    add_column :comentarios, :idBak, :string
    Comentario.update_all('idBak=id')
    remove_column :comentarios, :id
    add_index :comentarios, :created_at, unique: true
    add_column :comentarios, :idConsecutivo, 'int NOT NULL IDENTITY (1,1) '
    add_column :comentarios, :id, :nvarchar, limit: 10, null: false, default: 'zzz'
    Comentario.update_all('id=dbo.ConvertToBase(idConsecutivo, 32)')
    execute "ALTER TABLE comentarios ADD PRIMARY KEY (id);"
    remove_index :comentarios, :created_at
  end

  def down
    remove_column :comentarios, :idConsecutivo
    Comentario.update_all('id=idBak')
    remove_column :comentarios, :idBak
  end
end
