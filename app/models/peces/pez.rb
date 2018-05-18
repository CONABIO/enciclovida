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

  scope :join_criterios,-> { joins('LEFT JOIN peces_criterios ON peces.especie_id=peces_criterios.especie_id LEFT JOIN criterios on peces_criterios.criterio_id = criterios.id') }
  scope :join_propiedades,-> { joins('LEFT JOIN peces_propiedades ON peces.especie_id=peces_propiedades.especie_id LEFT JOIN propiedades on peces_propiedades.propiedad_id = propiedades.id') }
  scope :select_joins_peces, -> { select("peces.especie_id, peces.valor_total_promedio, criterios.valor, criterios.anio, propiedades.nombre_propiedad, propiedades.tipo_propiedad, propiedades.ancestry") }
  scope :filtros_peces, -> { select_joins_peces.join_criterios.join_propiedades.distinct.order(:valor_total, :tipo_imagen) }

  attr_accessor :guardar_manual
  before_save :guarda_valor_zonas, unless: :guardar_manual

  # Asigna los valores promedio por zona, de acuerdo a cada estado
  def guarda_valor_zonas
    asigna_valor_zonas
    save if changed?
  end

  # Regresa un array con los valores promedio por zona, de acuerdo a cada estado
  def dame_valor_zonas
    zonas = []

    criterio_propiedades.select('propiedades.*, anio, valor').cnp.each do |propiedad|
      zona_num = propiedad.root.nombre_zona_a_numero  # Para obtener la zona
      zonas[zona_num] = [] if zonas[zona_num].nil?
      cnp_valor = propiedad.nombre_cnp_a_valor.nil? ? propiedad.valor : propiedad.nombre_cnp_a_valor
      zonas[zona_num] << cnp_valor
    end

    return ['s']*6 unless zonas.any?
    completa_y_promedia_zonas(zonas)
  end

  def self.actualiza_todo_valor_zonas
    all.each do |p|
      p.guardar_manual = true
      p.guarda_valor_zonas
    end
  end

  def dame_valor_total
    valor_zonas = color_a_valor_zona.inject(:+)

  end


  private

  # Asigna los valores promedio por zona, de acuerdo a cada estado
  def asigna_valor_zonas
    self.valor_zonas = dame_valor_zonas.join('')
  end

  def completa_y_promedia_zonas(zonas)
    promedio_zonas = Array.new(6, -20)

    zonas.each_with_index do |val, index|
      valores = val || []
      estados_validos = (valores || []) - [-10,-20]

      if estados_validos.empty?
        estados_validos = valores
      end

      promedio_zona = if estados_validos.nil? || estados_validos.empty?
                        -20
                      else
                        estados_validos.inject(:+)/estados_validos.length
                      end

      promedio_zonas[index] = promedio_zona
    end

    valor_zona_a_color(promedio_zonas)
  end

  def valor_zona_a_color(promedios)
    zonas = []

    promedios.each_with_index do |promedio, index|
      case promedio
        when -20..-11
          zonas[index] = 's'
        when -10..-5
          zonas[index] = 'n'
        when 0..5
          zonas[index] = 'v'
        when 6..10
          zonas[index] = 'a'
        when 11..100
          zonas[index] = 'r'
        else
          zonas[index] = 's'
      end
    end

    zonas
  end

  # El inverso de valor_a_color
  def color_a_valor_zona
    zonas = []

    valor_zonas.split(',').each do |zona|
      case zona
        when 's'
          zonas << 0
        when 'n'
          zonas << 0
        when 'v'
          zonas << 0
        when 'a'
          zonas << 5
        when 'r'
          zonas << 20
        else
      end
    end
  end

end