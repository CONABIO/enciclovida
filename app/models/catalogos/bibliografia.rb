class Bibliografia < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.Bibliografia'
  self.primary_key = 'IdBibliografia'

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdBibliografia

  def personalizaBusqueda
    "#{self.autor} - #{self.titulo_publicacion} (#{self.anio})"
  end

end
