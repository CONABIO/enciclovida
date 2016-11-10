class ChangeCategoriaComentarioIdToCategoriaContenidoId < ActiveRecord::Migration
  def change
     change_table :comentarios do |t|
       t.rename :categoria_comentario_id, :categoria_contenido_id
     end
  end
end
