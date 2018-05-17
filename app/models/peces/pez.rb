class Pez < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='peces'
  self.primary_key='especie_id'

  has_many :peces_criterios, :class_name => 'PezCriterio', :foreign_key => :especie_id
  has_many :criterios, :through => :peces_criterios, :source => :criterio
  has_many :criterio_propiedades, :through => :criterios, :source => :propiedad

  has_many :peces_propiedades, :class_name => 'PezPropiedad', :foreign_key => :especie_id
  has_many :propiedades, :through => :peces_propiedades, :source => :propiedad

  belongs_to :especie

  # Completa el campo valor_zonas en la tabla peces para el pez en cuestion
  def dame_valor_zonas
    zonas = []

    criterio_propiedades.select('propiedades.*, anio, valor').cnp.each do |propiedad|
      zona_num = propiedad.root.nombre_zona_a_numero  # Para obtener la zona
      zonas[zona_num] = [] if zonas[zona_num].nil?
      zonas[zona_num] << propiedad.valor
    end

    return unless zonas.any?
    completa_y_promedia_zonas(zonas)
  end


  private

  def completa_y_promedia_zonas(zonas)
    promedio_zonas = Array.new(6, -1)

    zonas.each_with_index do |valores, index|
      promedio_zona = (valores.inject(:+))/valores.length
      promedio_zonas[index] = promedio_zona
    end

    valor_zona_a_color(promedio_zonas)
  end

  def valor_zona_a_color(promedios)
    zonas = []

    promedios.each_with_index do |promedio, index|
      case promedio
        when -1
          zonas[index] = 's'
        when 0..5
          zonas[index] = 'v'
        when 6..10
          zonas[index] = 'a'
        when 11..100
          zonas[index] = 'r'
      end
    end

    zonas
  end

end