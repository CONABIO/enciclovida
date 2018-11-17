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

      while datos[anio].nil?
        datos[anio] = {} unless datos[anio].present?
        datos[anio][:year] = anio

        datos[anio][:variableA] = 0
        datos[anio][:variableB] = 0
        datos[anio][:variableC] = 0
        datos[anio][:variableD] = 0
        datos[anio][:variableE] = 0
        datos[anio][:variableF] = 0
        datos[anio][:variableG] = 0
        datos[anio][:variableH] = 0
      end

      case d.campo_investigacion
      when 'Aquaculture'
        datos[anio][:variableA] = d.totales
      when 'Conservation'
        datos[anio][:variableB] = d.totales
      when 'Ecology'
        datos[anio][:variableC] = d.totales
      when 'Fisheries'
        datos[anio][:variableD] = d.totales
      when 'Oceanography'
        datos[anio][:variableE] = d.totales
      when 'Sociology'
        datos[anio][:variableF] = d.totales
      when 'Tourism'
        datos[anio][:variableG] = d.totales
      when 'Other'
        datos[anio][:variableH] = d.totales
      end
    end

    self.datos = datos.map{ |year,valor| valor }
  end

  def grafica2

  end

end