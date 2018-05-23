class Pez < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='peces'
  self.primary_key='especie_id'

  has_many :peces_criterios, :class_name => 'PezCriterio', :foreign_key => :especie_id, inverse_of: :pez, dependent: :destroy
  has_many :criterios, :through => :peces_criterios, :source => :criterio
  has_many :criterio_propiedades, :through => :criterios, :source => :propiedad

  has_many :peces_propiedades, :class_name => 'PezPropiedad', :foreign_key => :especie_id
  has_many :propiedades, :through => :peces_propiedades, :source => :propiedad

  belongs_to :especie

  scope :select_joins_peces, -> { select([:nombre_cientifico, :nombres_comunes, :valor_total, :valor_zonas, :imagen]).select('peces.especie_id') }

  scope :join_criterios,-> { joins('LEFT JOIN peces_criterios ON peces.especie_id=peces_criterios.especie_id LEFT JOIN criterios on peces_criterios.criterio_id = criterios.id') }
  scope :join_propiedades,-> { joins('LEFT JOIN peces_propiedades ON peces.especie_id=peces_propiedades.especie_id LEFT JOIN propiedades on peces_propiedades.propiedad_id = propiedades.id') }

  scope :join_criterios_propiedades,-> { joins('LEFT JOIN propiedades on criterios.propiedad_id = propiedades.id') }

  scope :filtros_peces, -> { select_joins_peces.join_criterios.join_propiedades.distinct.order(:valor_total, :tipo_imagen, :nombre_cientifico) }

  scope :nombres_peces, -> { select([:especie_id, :nombre_cientifico, :nombres_comunes])}
  scope :nombres_cientificos_peces, -> { select(:especie_id).select("nombre_cientifico as label")}
  scope :nombres_comunes_peces, -> { select(:especie_id).select("nombres_comunes as label")}

  validates_presence_of :especie_id
  attr_accessor :guardar_manual, :anio
  before_save :actualiza_pez, unless: :guardar_manual

  accepts_nested_attributes_for :peces_criterios, reject_if: :all_blank, allow_destroy: true

  # Corre los metodos necesarios para actualizar el pez
  def actualiza_pez
    asigna_valor_zonas
    asigna_valor_total
    asigna_nombre_cientifico
    asigna_nombres_comunes
    asigna_imagen
  end

  # Actualiza todos los servicios
  def self.actualiza_todo
    all.each do |p|
      p.guardar_manual = true
      p.actualiza_pez
      p.save if p.changed?
    end
  end

  # Asigna los valores promedio por zona, de acuerdo a cada estado
  def guarda_valor_zonas
    asigna_valor_zonas
    save if changed?
  end

  # Asigna los valores promedio por zona, de acuerdo a cada estado
  def asigna_valor_zonas
    zonas = Array.new(6, -20)  # COmpleta con Estatus no definido por default "s"
    asigna_anio

    criterio_propiedades.select('propiedades.*, valor').cnp.where('anio=?', anio).each do |propiedad|
      zona_num = propiedad.parent.nombre_zona_a_numero  # Para obtener la zona
      cnp_valor = propiedad.nombre_cnp_a_valor  # Obtiene el valor numerico
      cnp_valor = cnp_valor.nil? ? propiedad.valor : cnp_valor
      zonas[zona_num] = cnp_valor
    end

    self.valor_zonas = valor_cnp_a_color(zonas).join('')
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
    self.valor_total+= promedia_valores_cnp
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

  # Promedia el valor de la CNP por zona, solo valores con datos (v,a,r)
  def promedia_valores_cnp
    zonas = color_cnp_a_valor
    return 0 unless zonas.any?

    zonas.inject(:+)/zonas.length
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

  # Asocia el valor de la cnp a un color correspondiente
  def valor_cnp_a_color(zonas_array)
    zonas = []

    zonas_array.each do |zona|
      case zona
        when -20
          zonas << 's'
        when -10
          zonas << 'n'
        when 0
          zonas << 'v'
        when 5
          zonas << 'a'
        when 20
          zonas << 'r'
        else
          zonas << 's'
      end
    end

    zonas
  end

  # El inverso de valor_cnp_a_color, solo valores con datos (v,a,r)
  def color_cnp_a_valor
    zonas = []

    valor_zonas.split('').each do |zona|
      case zona
        when 'v'
          zonas << 0
        when 'a'
          zonas << 5
        when 'r'
          zonas << 20
      end
    end

    zonas
  end

  # Para sacar solo el año en cuestion
  def asigna_anio
    self.anio = anio || CONFIG.peces.anio || 2012
  end

end