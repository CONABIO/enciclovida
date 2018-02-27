class ChangeCategoriaComentarioIdToCategoriaContenidoId < ActiveRecord::Migration[5.1]
  def change
     change_table :comentarios do |t|
       t.rename :categoria_comentario_id, :categorias_contenido_id
     end
  end
end
