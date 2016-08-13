class AddAutoIncrementToBase32IdInComentarios < ActiveRecord::Migration
  def change
    remove_index :comentarios, :id
    add_index :comentarios, :created_at
    add_column :comentarios, :id_consecutivo, :integer
    add_index :comentarios, :id_consecutivo
  end
end


=begin
scriptAddConsecutivoComentarios.sql
/* Para evitar posibles problemas de pérdida de datos, debe revisar este script detalladamente antes de ejecutarlo fuera del contexto del diseñador de base de datos.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.comentarios
        DROP CONSTRAINT DF_comentarios_estatus
GO
ALTER TABLE dbo.comentarios
        DROP CONSTRAINT DF_comentarios_categoria_comentario_id
GO
CREATE TABLE dbo.Tmp_comentarios
        (
        id varchar(255) NOT NULL,
        comentario nvarchar(MAX) NOT NULL,
        correo nvarchar(255) NULL,
        nombre nvarchar(255) NULL,
        especie_id int NOT NULL,
        usuario_id int NULL,
        created_at datetime NOT NULL,
        updated_at datetime NULL,
        estatus int NOT NULL,
        ancestry nvarchar(255) NULL,
        fecha_estatus datetime NULL,
        usuario_id2 int NULL,
        categoria_comentario_id int NOT NULL,
        institucion nvarchar(255) NULL,
        id_consecutivo int NOT NULL IDENTITY (1, 1)
        )  ON [PRIMARY]
         TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_comentarios SET (LOCK_ESCALATION = TABLE)
GO
ALTER TABLE dbo.Tmp_comentarios ADD CONSTRAINT
        DF_comentarios_estatus DEFAULT ((1)) FOR estatus
GO
ALTER TABLE dbo.Tmp_comentarios ADD CONSTRAINT
        DF_comentarios_categoria_comentario_id DEFAULT ((26)) FOR categoria_comentario_id
GO
SET IDENTITY_INSERT dbo.Tmp_comentarios OFF
GO
IF EXISTS(SELECT * FROM dbo.comentarios)
         EXEC('INSERT INTO dbo.Tmp_comentarios (id, comentario, correo, nombre, especie_id, usuario_id, created_at, updated_at, estatus, ancestry, fecha_estatus, usuario_id2, categoria_comentario_id, institucion)
                SELECT id, comentario, correo, nombre, especie_id, usuario_id, created_at, updated_at, estatus, ancestry, fecha_estatus, usuario_id2, categoria_comentario_id, institucion FROM dbo.comentarios WITH (HOLDLOCK TABLOCKX)')
GO
DROP TABLE dbo.comentarios
GO
EXECUTE sp_rename N'dbo.Tmp_comentarios', N'comentarios', 'OBJECT'
GO
ALTER TABLE dbo.comentarios ADD CONSTRAINT
        PK_comentarios PRIMARY KEY CLUSTERED
        (
        created_at
        ) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT

=end