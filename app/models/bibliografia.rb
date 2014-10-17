class Bibliografia < ActiveRecord::Base

  self.table_name='bibliografias'
  self.primary_key='id'

  has_many :nombres_regiones_bibligrafias
  has_many :especies_bibliografias

  def personalizaBusqueda
    "#{self.autor} - #{self.titulo_publicacion} (#{self.anio})"
  end

end
