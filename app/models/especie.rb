class Especie < ActiveRecord::Base

  self.table_name='especies'
  self.primary_key='id'

  has_one :proveedor
  belongs_to :categoria_taxonomica
  has_many :especies_regiones, :class_name => 'EspecieRegion', :foreign_key => 'especie_id', :dependent => :destroy
  has_many :especies_catalogos, :class_name => 'EspecieCatalogo', :dependent => :destroy
  has_many :nombres_regiones, :class_name => 'NombreRegion', :dependent => :destroy
  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :dependent => :destroy
  has_many :especies_estatus, :class_name => 'EspecieEstatus', :foreign_key => :especie_id1, :dependent => :destroy
  has_many :especies_bibliografias, :class_name => 'EspecieBibliografia', :dependent => :destroy
  has_many :taxon_photos, :order => 'position ASC, id ASC', :dependent => :destroy
  has_many :photos, :through => :taxon_photos
  has_many :nombres_comunes, :through => :nombres_regiones, :source => :nombre_comun
  has_many :tipos_distribuciones, :through => :especies_regiones, :source => :tipo_distribucion
  has_many :estados_conservacion, :through => :especies_catalogos, :source => :catalogo
  has_many :metadatos_especies, :class_name => 'MetadatoEspecie', :foreign_key => 'especie_id'
  has_many :metadatos, :through => :metadatos_especies#, :source => :metadato

  has_ancestry :ancestry_column => :ancestry_ascendente_directo

  accepts_nested_attributes_for :especies_catalogos, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :especies_regiones, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :nombres_regiones, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :nombres_regiones_bibliografias, :reject_if => :all_blank, :allow_destroy => true

  scope :caso_insensitivo, ->(columna, valor) { where("LOWER(#{columna}) LIKE LOWER('%#{valor}%')") }
  scope :caso_empieza_con, ->(columna, valor) { where("#{columna} LIKE '#{valor}%'") }
  scope :caso_sensitivo, ->(columna, valor) { where("#{columna}='#{valor}'") }
  scope :caso_termina_con, ->(columna, valor) { where("#{columna} LIKE '%#{valor}'") }
  scope :caso_fecha, ->(columna, valor) { where("CAST(#{columna} AS TEXT) LIKE '%#{valor}%'") }
  scope :caso_ids, ->(columna, valor) { where(columna => valor) }
  scope :caso_rango_valores, ->(columna, rangos) { where("#{columna} IN (#{rangos})") }
  scope :caso_status, ->(status) { where(:estatus => status.to_i) }
  scope :ordenar, ->(columna, orden) { order("#{columna} #{orden}") }

  #Los joins explicitos fueron necesarios ya que por default "joins", es un RIGHT JOIN
  scope :especies_regiones_join, -> { joins('LEFT JOIN especies_regiones ON especies_regiones.especie_id=especies.id') }
  scope :nombres_comunes_join, -> { joins('LEFT JOIN nombres_regiones ON nombres_regiones.especie_id=especies.id').
      joins('LEFT JOIN nombres_comunes ON nombres_comunes.id=nombres_regiones.nombre_comun_id') }
  scope :region_join, -> { joins('LEFT JOIN regiones ON regiones.id=especies_regiones.region_id') }
  scope :tipo_region_join, -> { joins('LEFT JOIN tipos_regiones ON tipos_regiones.id=regiones.tipo_region_id') }
  scope :tipo_distribucion_join, -> { especies_regiones_join.joins('LEFT JOIN tipos_distribuciones ON tipos_distribuciones.id=especies_regiones.tipo_distribucion_id') }
  scope :caso_nombre_bibliografia, -> { joins('LEFT JOIN nombres_regiones_bibliografias ON nombres_regiones_bibliografias.especie_id=especie.id').
      joins('LEFT JOIN bibliografias ON bibliografias.id=nombres_regiones_bibliografias.bibliografia_id') }
  scope :catalogos_join, -> { joins('LEFT JOIN especies_catalogos ON especies_catalogos.especie_id=especies.id').
      joins('LEFT JOIN catalogos ON catalogos.id=especies_catalogos.catalogo_id') }
  scope :categoria_taxonomica_join, -> { joins('LEFT JOIN categorias_taxonomicas ON categorias_taxonomicas.id=especies.categoria_taxonomica_id') }
  scope :datos, -> { joins('LEFT JOIN especies_regiones ON especies.id=especies_regiones.especie_id').joins('LEFT JOIN categoria_taxonomica') }

  POR_PAGINA_PREDETERMINADO = 10

  POR_PAGINA = [10, 20, 50, 100, 200, 500, 1000]
  CON_REGION = [19, 50]
  ESTATUS = [
      [2, 'válido'],
      [1, 'sinónimo']
  ]

  ESTATUS_VALOR = {
      ESTATUS[0][0] => ESTATUS[0][1],
      ESTATUS[1][0] => ESTATUS[1][1]
  }

  ESTATUS_SIMBOLO = {
      2 => '',
      1 =>''
  }

  ESTATUS_SIGNIFICADO = {
      2 => 'válido',
      1 =>'sinónimo'
  }

  ESPECIES_Y_MENORES = %w(19 20 21 22 23 24 50 51 52 53 54 55)

  BUSQUEDAS_TEXTO = {
      1 => 'contiene',
      2 => 'empieza con',
      3 => 'igual a',
      4 => 'termina con'
  }

  BUSQUEDAS_ATRIBUTO = {
      'nombre_cientifico' => 'nombre científico',
      'nombre_comun' => 'nombre común',
      'catalogos.descripcion' => 'característica del taxón',
      'nombre_autoridad' => 'autoridad'
  }

  BUSQUEDAS_COMPARADOR = {
      '>' => 'menor a',
      '>=' => 'menor o igual a',
      '=' => 'igual a',
      '<=' => 'mayor o igual a',
      '<' => 'mayor a'
  }

  NIVEL_CATEGORIAS = [
      ['inferior o igual a', '>='],
      ['inferior a', '>'],
      ['igual a', '='],
      ['superior o igual a', '<='],
      ['superior a', '<']
  ]

  SPECIES_OR_LOWER = %w(especie subespecie variedad subvariedad forma subforma)
  BAJO_GENERO = %w(género subgénero sección subsección serie subserie)

  GRUPOS_ICONICOS = {
      # Reino Animalia
      'Animalia' => %w(Animales icon-vacio sin-color),
      'Mammalia' => %w(Mamíferos icon-mamifero sin-color),
      'Aves' => %w(Aves icon-aves #821b18),
      'Reptilia' => %w(Reptiles icon-reptil #cb4b19),
      'Amphibia' => %w(Anfibios icon-anfibio #ba191d),
      'Actinopterygii' => ['Peces óseos', 'icon-peces', '#9d331a'],
      'Petromyzontida' => %w(Lampreas icon-vacio sin-color),
      'Myxini' => %w(Mixines icon-vacio sin-color),
      'Chondrichthyes' => ['Tiburones, rayas y quimeras', 'icon-tiburon_raya', '#c96016'],
      'Cnidaria' => ['Medusas, corales y anémonas', 'icon-vacio', 'sin-color'],
      'Arachnida' => %w(Arácnidos icon-arana #985f18),
      'Myriapoda' => ['Ciempiés y milpies', 'icon-ciempies', '#a5752a'],
      'Annelida' => ['Lombrices y gusanos marinos', 'icon-lombrices', '#c97e0f'],
      'Insecta' => %w(Insectos icon-insectos #d88f2b),
      'Porifera' => %w(Esponjas icon-vacio sin-color),
      'Echinodermata' => ['Estrellas y erizos de mar', 'icon-estrellamar', '#7b6927'],
      'Mollusca' => ['Caracoles, almejas y pulpos', ' icon-caracol', '#6f502c'],
      'Crustacea' => ['Camarones y cangrejos', 'icon-crustaceo', '#4c351a'],

      # Reino Plantae
      'Plantae' => %w(Plantas icon-plantas #00802f),
      'Bryophyta' => ['Musgos, hepáticas y antoceros', 'icon-musgo', '#7a7544'],
      'Pteridophyta' => %w(Helechos icon-helecho #adb280),
      'Cycadophyta' => %w(Cícadas icon-cicada #545a35),
      'Gnetophyta' => %w(Canutillos icon-vacio sin-color),
      'Liliopsida' => ['Pastos y palmeras', 'icon-pastos_palmeras', '#114722'],
      'Coniferophyta' => ['Pinos y cedros', 'icon-pino', '#788c4a'],
      'Magnoliopsida' => ['Margaritas y magnolias', 'icon-magnolias', '#495925'],

      # Reino Protoctista
      'Protoctista' => %w(Arquea icon-arquea #00455f),

      # Reino Fungi
      'Fungi' => %w(Hongos icon-hongos #501766),

      # Reino Prokaryonte (desde 1930 ?)
      'Prokaryotae' => %w(Bacterias icon-bacterias #9a1a5d)
  }

  def self.por_categoria(busqueda)
    # Las condiciones y el join son los mismos pero cambia el select
    sql = "select('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4) AS nivel,"
    sql << "count(CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4)) as cuantos,"
    sql << "nombre_categoria_taxonomica')"

    busq = busqueda.sub(/select\(.+mica\'\)/, sql)
    busq << ".group('CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4), nombre_categoria_taxonomica')"
    busq << ".order('nivel ASC')"
    eval(busq)
  end

  # Override assignment method provided by has_many to ensure that all
  # callbacks on photos and taxon_photos get called, including after_destroy
  def photos=(new_photos)
    taxon_photos.each do |taxon_photo|
      taxon_photo.destroy unless new_photos.detect{|p| p.id == taxon_photo.photo_id}
    end
    new_photos.each do |photo|
      taxon_photos.build(:photo => photo) unless photos.detect{|p| p.id == photo.id}
    end
  end

  def species_or_lower?(cat=nil, con_genero=false)
    if con_genero
      SPECIES_OR_LOWER.include?(cat || categoria_taxonomica.nombre_categoria_taxonomica) || BAJO_GENERO.include?(cat || categoria_taxonomica.nombre_categoria_taxonomica)
    else
      SPECIES_OR_LOWER.include?(cat || categoria_taxonomica.nombre_categoria_taxonomica)
    end
  end

  #
  # Fetches associated user-selected FlickrPhotos if they exist, otherwise
  # gets the the first :limit Create Commons-licensed photos tagged with the
  # taxon's scientific name from Flickr.  So this will return a heterogeneous
  # array: part FlickrPhotos, part api responses
  #
  def photos_with_backfill(options = {})
    options[:limit] ||= 9
    chosen_photos = taxon_photos.includes(:photo).limit(options[:limit]).map{|tp| tp.photo}
    if chosen_photos.size < options[:limit]
      new_photos = Photo.includes({:taxon_photos => :especie}).
          order("taxon_photos.id ASC").
          limit(options[:limit] - chosen_photos.size).
          where("especies.ancestry_ascendente_directo LIKE '#{ancestry_ascendente_directo}/#{id}%'")#.includes()
      if new_photos.size > 0
        new_photos = new_photos.where("photos.id NOT IN (?)", chosen_photos)
      end
      chosen_photos += new_photos.to_a
    end
    flickr_chosen_photos = []
    if !options[:skip_external] && chosen_photos.size < options[:limit] && self.auto_photos
      begin
        r = flickr.photos.search(
            :tags => name.gsub(' ', '').strip,
            :per_page => options[:limit] - chosen_photos.size,
            :license => '1,2,3,4,5,6', # CC licenses
            :extras => 'date_upload,owner_name,url_s,url_t,url_s,url_m,url_l,url_o,owner_name,license',
            :sort => 'relevance'
        )
        r = [] if r.blank?
        flickr_chosen_photos = if r.respond_to?(:map)
                                 r.map{|fp| fp.respond_to?(:url_s) && fp.url_s ? FlickrPhoto.new_from_api_response(fp) : nil}.compact
                               else
                                 []
                               end
      rescue FlickRaw::FailedResponse, EOFError => e
        Rails.logger.error "EXCEPTION RESCUE: #{e}"
        Rails.logger.error e.backtrace.join("\n\t")
      end
    end
    flickr_ids = chosen_photos.map{|p| p.native_photo_id}
    chosen_photos += flickr_chosen_photos.reject do |fp|
      flickr_ids.include?(fp.id)
    end
    chosen_photos
  end

  def photos_cache_key
    "taxon_photos_#{id}"
  end

  def photos_with_external_cache_key
    "taxon_photos_external_#{id}"
  end

  def info_tab_cache_key
    "views/info_tab_#{id}"
  end

  def pon_foto_principal
    # Antes de cambiar de base ya que photos esta en Rails.env
    fotos = photos.order(:type)
    return unless fotos.any?
    foto_principal = fotos.first.thumb_url

    id_bio = Bases.id_en_vista_a_id_original id
    numero_base = Bases.id_original_a_numero_base id
    Bases.conecta_a CONFIG.bases[numero_base]

    taxon_bio = EspecieBio.find(id_bio)
    taxon_bio.foto_principal = foto_principal
    taxon_bio.evita_before_save = true
    taxon_bio.avoid_ancestry = true
    taxon_bio.save if taxon_bio.changed?
    Bases.conecta_a Rails.env
  end

  # Guarda en cache el path del KMZ
  def snib_cache_key
    "snib_#{id}"
  end

  def completa_blurrily
    FUZZY_NOM_CIEN.put(nombre_cientifico, id)
  end

  def exporta_redis
    ic = icono.present? ? "<img src='/assets/app/iconic_taxa/#{icono}' title='#{nombre_icono}' class='img-thumbnail icono-redis' \>" :
        "<img src='/assets/app/iconic_taxa/sin_icono.png' title='#{nombre_cientifico}' class='img-thumbnail icono-redis' \>"

    data = ''
    data << "{\"id\":#{id},"
    data << "\"term\":\"#{nombre_cientifico}\","
    data << "\"data\":{\"nombre_comun\":\"#{nombre_comun_principal.try(:limpia)}\", "
    data <<  "\"icono\":\"#{ic.limpia}\", \"autoridad\":\"#{nombre_autoridad.limpia}\", \"id\":#{id}, \"estatus\":\"#{Especie::ESTATUS_VALOR[estatus]}\"}"
    data << "}\n"
  end

  def cat_tax_asociadas
    limites = Bases.limites(id)
    rama = %w(0)

    # Quiere decir que es con las categorias de phylum, clasificadas por el nivel2
    if ancestry_ascendente_directo.include?('1000001') || id == 1000001
      rama = %w(1 2)
    end

    if I18n.locale.to_s == 'es-cientifico'
      CategoriaTaxonomica.select('id,nombre_categoria_taxonomica,CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').
          where(:id => limites[:limite_inferior]..limites[:limite_superior]).where("nivel2 IN (#{rama.join(',')}) OR nombre_categoria_taxonomica='Reino'").order('nivel')
    else # Con las categorias de division
      CategoriaTaxonomica.select('id,nombre_categoria_taxonomica,CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').
          where(:id => limites[:limite_inferior]..limites[:limite_superior]).
          caso_rango_valores('nombre_categoria_taxonomica', CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.map{|c| "'#{c}'"}.join(',')).
          where("nivel2 IN (#{rama.join(',')}) OR nombre_categoria_taxonomica='Reino'").order('nivel')
    end
  end

  def self.asigna_grupo_iconico
    GRUPOS_ICONICOS.keys.each do |grupo|
      puts grupo
      taxon = Especie.where(:nombre_cientifico => grupo).first
      puts "Hubo un error al buscar el taxon: #{grupo}" unless taxon

      descendentes = taxon.subtree_ids
      descendentes.each_slice(20000).to_a.each do |grupo_20k| # Fue necesario dividir el query ya que con muchos argumentos no funciona
        Especie.where("id IN (#{grupo_20k.join(',')})").update_all(:icono => "#{GRUPOS_ICONICOS[grupo][1]}|#{GRUPOS_ICONICOS[grupo][2]}", :nombre_icono => GRUPOS_ICONICOS[grupo][0])
      end
    end
  end
end
