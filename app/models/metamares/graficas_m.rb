class Metamares::GraficasM

  attr_accessor :datos

  def initialize
    self.datos = {}
  end

  # Gráfica por año de publicacion contra campo de investigación
  def año_pub_x_campo_inv
    q = Metamares::Proyecto.select('COUNT(campo_investigacion) AS totales, publicacion_anio, campo_investigacion').
        left_joins(:dato).where('publicacion_anio IS NOT NULL').group('publicacion_anio, campo_investigacion').order('publicacion_anio')

    q.each do |d|
      datos[]
    end
  end

end