class Metamares::GraficasM

  attr_accessor :datos

  def initialize
    self.datos = {}
  end

  # Gráfica por año de publicacion contra campo de investigación
  def grafica1
    q = Metamares::Proyecto.select('COUNT(campo_investigacion) AS totales, publicacion_anio, campo_investigacion').
        left_joins(:dato).where('publicacion_anio IS NOT NULL').group('publicacion_anio, campo_investigacion').order('publicacion_anio')

    q.each do |d|
      anio = d.publicacion_anio[0..3].to_i

      datos[anio] = {} unless datos[anio].present?
      datos[anio][d.campo_investigacion] = d.totales
    end
  end

end