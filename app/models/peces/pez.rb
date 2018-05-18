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
  scope :select_joins_peces, -> { select([:nombre_cientifico, :nombres_comunes, :valor_total, :valor_zonas, :imagen]).select('peces.especie_id, valor, anio, nombre_propiedad, tipo_propiedad, ancestry') }
  scope :filtros_peces, -> { select_joins_peces.join_criterios.join_propiedades.distinct.order(:valor_total, :tipo_imagen, :nombre_cientifico) }

  attr_accessor :guardar_manual, :anio
  after_save :actualiza_pez, unless: :guardar_manual

  # Corre los metodos necesarios para actualizar el pez
  def actualiza_pez
    guarda_valor_zonas
    guarda_valor_total
    guarda_nombre_cientifico
    guarda_nombres_comunes
    guarda_imagen
  end

  # Asigna los valores promedio por zona, de acuerdo a cada estado
  def guarda_valor_zonas
    asigna_valor_zonas
    save if changed?
  end

  # Asigna los valores promedio por zona, de acuerdo a cada estado
  def asigna_valor_zonas
    zonas = []
    asigna_anio

    criterio_propiedades.select('propiedades.*, valor').cnp.where('anio=?', anio).each do |propiedad|
      zona_num = propiedad.root.nombre_zona_a_numero  # Para obtener la zona
      zonas[zona_num] = [] if zonas[zona_num].nil?
      cnp_valor = propiedad.nombre_cnp_a_valor.nil? ? propiedad.valor : propiedad.nombre_cnp_a_valor
      zonas[zona_num] << cnp_valor
    end

    return ['s']*6 unless zonas.any?
    self.valor_zonas = completa_y_promedia_zonas(zonas).join('')
  end

  def self.actualiza_todo_valor_zonas
    all.each do |p|
      p.guardar_manual = true
      p.guarda_valor_zonas
    end
  end

  def guarda_valor_total
    asigna_valor_total
    save if changed?
  end

  # Asigna el valor total del pez, sirve para la calificacion y ordenamiento
  def asigna_valor_total
    asigna_anio
    self.valor_total = 0

    propiedades = criterio_propiedades.select('valor').where('anio=?', anio)
    self.valor_total+= propiedades.tipo_capturas.map(&:valor).inject(:+).to_i
    self.valor_total+= propiedades.tipo_vedas.map(&:valor).inject(:+).to_i
    self.valor_total+= propiedades.procedencias.map(&:valor).inject(:+).to_i
    self.valor_total+= propiedades.pesquerias.map(&:valor).inject(:+).to_i
    self.valor_total+= propiedades.nom.map(&:valor).inject(:+).to_i
    self.valor_total+= propiedades.iucn.map(&:valor).inject(:+).to_i
    self.valor_total+= color_a_valor_zona.inject(:+)
  end

  def self.actualiza_todo_valor_total
    all.each do |p|
      p.guardar_manual = true
      p.guarda_valor_total
    end
  end

  def guarda_imagen
    asigna_imagen
    save if changed?
  end

  # Asigna la ilustracion, foto o ilustracion, asi como el tipo de foto
  def asigna_imagen
    # Trata de asignar la ilustracion
    bdi = BDIService.new
    res = bdi.dameFotos(taxon: especie, campo: 528, autor: 'Sergio de la Rosa Martínez', autor_campo: 80, ilustraciones: true)

    if res[:estatus] == 'OK'
      if res[:fotos].any?
        self.imagen = res[:fotos].first.medium_url
        self.tipo_imagen = 1
        return
      end
    end

    # Trata de asignar la foto principal
    if a = especie.adicional
      foto = a.foto_principal

      if foto.present?
        self.imagen = foto
        self.tipo_imagen = 2
        return
      end
    end

    # Asignar la silueta
    self.imagen = '/assets/app/peces/silueta.png'
    self.tipo_imagen = 3
  end

  def self.actualiza_todo_imagen
    all.each do |p|
      p.guardar_manual = true
      p.guarda_imagen
    end
  end

  # BORRAR en centralizacion
  def guarda_nombre_cientifico
    asigna_nombre_cientifico
    save if changed?
  end

  # BORRAR en centralizacion
  def asigna_nombre_cientifico
    self.nombre_cientifico = especie.nombre_cientifico
  end

  # BORRAR en centralizacion
  def self.actualiza_todo_nombre_cientifico
    all.each do |p|
      p.guardar_manual = true
      p.guarda_nombre_cientifico
    end
  end

  # BORRAR en centralizacion
  def guarda_nombres_comunes
    asigna_nombres_comunes
    save if changed?
  end

  # BORRAR en centralizacion
  def asigna_nombres_comunes
    nombres = especie.nombres_comunes_todos.map{|e| e.values.flatten}.flatten.join(',')
    self.nombres_comunes = nombres if nombres.present?
  end

  # BORRAR en centralizacion
  def self.actualiza_todo_nombres_comunes
    all.each do |p|
      p.guardar_manual = true
      p.guarda_nombres_comunes
    end
  end


  private

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

    valor_zonas.split('').each do |zona|
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
          zonas << 0
      end
    end

    zonas
  end

  def asigna_anio
    # Para sacar solo el año en cuestion
    self.anio = anio || CONFIG.peces.anio || 2012
  end

end