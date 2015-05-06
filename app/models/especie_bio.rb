class EspecieBio < ActiveRecord::Base

  self.table_name='Nombre'
  self.primary_key='IdNombre'

  alias_attribute :id, :IdNombre
  alias_attribute :categoria_taxonomica_id, :IdCategoriaTaxonomica
  alias_attribute :nombre, :Nombre
  alias_attribute :id_nombre_ascendente, :IdNombreAscendente
  alias_attribute :id_ascend_obligatorio, :IdAscendObligatorio
  alias_attribute :nombre_autoridad, :NombreAutoridad

  #esto es cuando se corre un script desde consola
  cattr_accessor :evita_before_save

  has_one :proveedor
  belongs_to :categoria_taxonomica, :class_name => 'CategoriaTaxonomicaBio', :foreign_key => 'IdCategoriaTaxonomica'
  has_many :especies_regiones, :class_name => 'EspecieRegion', :foreign_key => 'especie_id', :dependent => :destroy
  has_many :especies_catalogos, :class_name => 'EspecieCatalogo', :dependent => :destroy
  has_many :nombres_regiones, :class_name => 'NombreRegionBio', :foreign_key => 'IdNombre', :dependent => :destroy
  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :dependent => :destroy
  has_many :especies_estatuses, :class_name => 'EspecieEstatus', :foreign_key => :especie_id1, :dependent => :destroy
  has_many :especies_bibliografias, :class_name => 'EspecieBibliografia', :dependent => :destroy
  has_many :taxon_photos, :order => 'position ASC, id ASC', :dependent => :destroy
  has_many :photos, :through => :taxon_photos
  has_many :nombres_comunes, :through => :nombres_regiones, :source => :nombre_comun

  #Existe un cattr_accesor :avoid_ancestry (false default) por si el update se hace manual
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

  #Los joins explicitos fueron necesarios ya que por default la sentencia es un RIGHT JOIN
  scope :especies_regiones_join, -> { joins('LEFT JOIN especies_regiones ON especies_regiones.especie_id=especies.id') }
  scope :nombres_comunes_join, -> { joins('LEFT JOIN nombres_regiones ON nombres_regiones.especie_id=especies.id').
      joins('LEFT JOIN nombres_comunes ON nombres_comunes.id=nombres_regiones.nombre_comun_id') }
  scope :region_join, -> { joins('LEFT JOIN regiones ON regiones.id=especies_regiones.region_id') }
  scope :tipo_distribucion_join, -> { joins('LEFT JOIN tipos_distribuciones ON tipos_distribuciones.id=especies_regiones.tipo_distribucion_id') }
  scope :caso_nombre_bibliografia, -> { joins('LEFT JOIN nombres_regiones_bibliografias ON nombres_regiones_bibliografias.especie_id=especie.id').
      joins('LEFT JOIN bibliografias ON bibliografias.id=nombres_regiones_bibliografias.bibliografia_id') }
  scope :catalogos_join, -> { joins('LEFT JOIN especies_catalogos ON especies_catalogos.especie_id=especies.id').
      joins('LEFT JOIN catalogos ON catalogos.id=esepcies_catalogos.catalogo_id') }
  scope :categoria_taxonomica_join, -> { joins('LEFT JOIN CategoriaTaxonomica ON CategoriaTaxonomica.IdCategoriaTaxonomica=Nombre.IdCategoriaTaxonomica') }

  before_save :completa_datos, :unless => :evita_before_save

  POR_PAGINA_PREDETERMINADO = 10

  POR_PAGINA = [10, 20, 50, 100, 200, 500, 1000]
  CON_REGION = [19, 50]
  ESTATUS = [
      [2, 'válido/correcto'],
      [1, 'sinónimo']
  ]

  ESTATUS_SIMBOLO = {
      2 => '2',
      1 =>'1'
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

  CAMPOS_A_MOSTRAR = {
      '>' => 'menor a',
      '>=' => 'menor o igual a',
      '=' => 'igual a',
      '<=' => 'mayor o igual a',
      '<' => 'mayor a'
  }

  SPECIES_OR_LOWER = %w(especie subespecie variedad subvariedad forma subforma)

  CATEGORIAS_DIVISION = {
      1 => {
          0 => 'Reino',
          1 => 'Subreino'
      },
      2 => {
          0 => 'División',
          1 => 'Subdivisión'
      },
      3 => {
          0 => 'Clase',
          1 => 'Subclase',
          2 => 'Superorden'
      },
      4 => {
          0 => 'Orden',
          1 => 'Suborden'
      },
      5 => {
          0 => 'Familia',
          1 => 'Subfamilia',
          2 => {
              0 => 'Tribu',
              1 => 'Subtribu'
          }
      },
      6 => {
          0 => 'Género',
          1 => 'Subgénero',
          2 => {
              0 => 'Sección',
              1 => 'Subsección'
          },
          3 => {
              0 => 'Serie',
              1 => 'Subserie'
          }
      },
      7 => {
          0 => 'Especie',
          1 => 'Subespecie',
          2 => {
              0 => 'Variedad',
              1 => 'Subvariedad'
          },
          3 => {
              0 => 'Forma',
              1 => 'Subforma'
          }
      }
  }

  CATEGORIAS_PHYLUM = {
      1 => {
          0 => 'Reino',
          1 => 'Subreino',
          2 => 'Superphylum'
      },
      2 => {
          0 => 'Phylum',
          1 => 'Subphylum',
          2 => 'Superclase',
          3 => 'Grado'
      },
      3 => {
          0 => 'Clase',
          1 => 'Subclase',
          2 => 'Infraclase',
          3 => 'Superorden'
      },
      4 => {
          0 => 'Orden',
          1 => 'Suborden',
          2 => 'Infraorden',
          3 => 'Superfamilia'
      },
      5 => {
          0 => 'Familia',
          1 => 'Subfamilia',
          2 => 'Supertribu',
          3 => {
              0 => 'Tribu',
              1 => 'Subtribu'
          }
      },
      6 => {
          0 => 'Género',
          1 => 'Subgénero',
          2 => {
              0 => 'Sección',
              1 => 'Subsección'
          },
          3 => {
              0 => 'Serie',
              1 => 'Subserie'
          }
      },
      7 => {
          0 => 'Especie',
          1 => 'Subespecie',
          2 => {
              0 => 'Variedad',
              1 => 'Subvariedad'
          },
          3 => {
              0 => 'Forma',
              1 => 'Subforma'
          }
      }
  }

  # Lenguas aceptadas de NaturaLista
  LENGUAS_ACEPTADAS = %w(spanish espanol_mexico huasteco maya maya_peninsular mayan_languages mazateco mixteco mixteco_de_yoloxochitl totonaco otomi nahuatl zapoteco english)

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

  def species_or_lower?
    SPECIES_OR_LOWER.include? categoria_taxonomica.nombre_categoria_taxonomica
  end

  def self.dameIdsDelNombre(nombre, tipo=nil)
    identificadores=''

    sentencia="SELECT nr.especie_id AS ids FROM nombres_regiones nr
    LEFT JOIN nombres_comunes nc ON nc.id=nr.nombre_comun_id
    WHERE lower_unaccent(nc.nombre_comun) LIKE lower_unaccent('%#{nombre.gsub("'",  "''")}%')"

    sentencia+="UNION SELECT e.id from especies e WHERE lower_unaccent(e.nombre) LIKE lower_unaccent('%#{nombre.gsub("'",  "''")}%')" if tipo.nil?

    sentencia=Especie.find_by_sql(sentencia)

    sentencia.each do |i|
      identificadores+="#{i.ids}, "
    end

    identificadores[0..-3]
  end


  def self.dameIdsDeLaRegion(nombre)
    identificadores=''
    Especie.find_by_sql("SELECT DISTINCT er.especie_id AS ids FROM especies_regiones er
                              LEFT JOIN regiones r ON er.region_id=r.id
                              WHERE lower_unaccent(r.nombre_region) LIKE lower_unaccent('%#{nombre.gsub("'",  "''")}%') ORDER BY ids").each do |i|
      identificadores+="#{i.ids}, "
    end
    identificadores[0..-3]
  end


  def self.dameIdsDeLaDistribucion(distribucion)
    identificadores=''
    Especie.find_by_sql("SELECT DISTINCT er.especie_id AS ids FROM especies_regiones er
                                    WHERE tipo_distribucion_id=#{distribucion} ORDER BY ids;").each do |i|
      identificadores+="#{i.ids}, "
    end
    identificadores[0..-3]
  end

  def self.dameIdsDeConservacion(nombre)
    identificadores=''
    Especie.find_by_sql("SELECT DISTINCT ec.especie_id AS ids FROM especies_catalogos ec
                              LEFT JOIN catalogos c ON ec.catalogo_id=c.id
                              WHERE lower_unaccent(c.descripcion) LIKE lower_unaccent('%#{nombre.gsub("'",  "''")}%') ORDER BY ids").each do |i|
      identificadores+="#{i.ids}, "
    end
    identificadores[0..-3]
  end

  def self.dameIdsCategoria(categoria, id)
    identificadores=''
    Especie.find(id).descendant_ids.each do |des|
      if Especie.find(des).categoria_taxonomica_id == categoria.to_i
        identificadores+="#{des}, "
      end
    end
    identificadores[0..-3]
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

  def ancestry_directo
    if id_nombre_ascendente != id
      self.ancestry_ascendente_directo = id_nombre_ascendente
      valor=true
      id_asc=id_nombre_ascendente

      while valor do
        subEsp=EspecieBio.find(id_asc)

        if subEsp.id_nombre_ascendente == subEsp.id
          valor=false
        else
          self.ancestry_ascendente_directo="#{subEsp.id_nombre_ascendente}/#{ancestry_ascendente_directo}"
          id_asc=subEsp.id_nombre_ascendente
        end
      end
    end
  end

  def ancestry_obligatorio
    if id_ascend_obligatorio != id
      self.ancestry_ascendente_obligatorio = id_ascend_obligatorio
      valor=true
      id_asc=id_ascend_obligatorio

      while valor do
        subEsp=EspecieBio.find(id_asc)

        if subEsp.id_ascend_obligatorio == subEsp.id
          valor=false
        else
          self.ancestry_ascendente_obligatorio="#{subEsp.id_ascend_obligatorio}/#{ancestry_ascendente_obligatorio}"
          id_asc=subEsp.id_ascend_obligatorio
        end
      end
    end
  end

  def completa_datos
    ancestry_directo
    ancestry_obligatorio
    pon_nombre_cientifico
    #completa_redis?
  end

  def pon_nombre_cientifico
    self.nombre_cientifico = ''
    return self.nombre_cientifico = nombre.limpiar if is_root?
    subgenero = ''
    seccion = ''

    EspecieBio.select('Nombre.IdNombre, Nombre.Nombre, NombreCategoriaTaxonomica AS nombre_categoria_taxonomica').
        categoria_taxonomica_join.caso_rango_valores('Nombre.IdNombre', ancestor_ids.reverse.join(',')).order('IdNombre DESC').each do |taxon|

      subgenero << " (#{taxon.nombre.limpiar}) " if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'subgenero'
      seccion << " sect. #{taxon.nombre.limpiar} " if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'seccion'

      case I18n.transliterate(categoria_taxonomica.nombre_categoria_taxonomica).downcase

        when 'subgenero'
          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'genero'
            self.nombre_cientifico = "#{taxon.nombre.limpiar} (#{nombre.limpiar})"
          end

        when 'especie'
          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'genero'
            self.nombre_cientifico << taxon.nombre.limpiar
            self.nombre_cientifico << subgenero
            self.nombre_cientifico << seccion
            self.nombre_cientifico << " #{nombre.limpiar}"
            break
          end

        when 'subespecie'
          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'especie'
            self.nombre_cientifico << taxon.nombre.limpiar
            self.nombre_cientifico << " subsp. #{nombre.limpiar}"
          end

          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'genero'
            self.nombre_cientifico = "#{taxon.nombre.limpiar} #{subgenero} #{seccion} #{nombre_cientifico}"
            break
          end

        when 'variedad'
          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'especie'
            self.nombre_cientifico << taxon.nombre.limpiar
            self.nombre_cientifico << " var. #{nombre.limpiar}"
          end

          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'genero'
            self.nombre_cientifico = "#{taxon.nombre.limpiar} #{subgenero} #{seccion} #{nombre_cientifico}"
            break
          end

        when 'forma'
          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'especie'
            self.nombre_cientifico << taxon.nombre.limpiar
            self.nombre_cientifico << " f. #{nombre.limpiar}"
          end

          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'genero'
            self.nombre_cientifico = "#{taxon.nombre.limpiar} #{subgenero} #{seccion} #{nombre_cientifico}"
            break
          end

        when 'subvariedad'
          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'especie'
            self.nombre_cientifico << taxon.nombre.limpiar
            self.nombre_cientifico << " subvar. #{nombre.limpiar}"
          end

          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'genero'
            self.nombre_cientifico = "#{taxon.nombre.limpiar} #{subgenero} #{seccion} #{nombre_cientifico}"
            break
          end

        when 'subforma'
          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'especie'
            self.nombre_cientifico << taxon.nombre.limpiar
            self.nombre_cientifico << " subf. #{nombre.limpiar}"
          end

          if I18n.transliterate(taxon.nombre_categoria_taxonomica).downcase == 'genero'
            self.nombre_cientifico = "#{taxon.nombre.limpiar} #{subgenero} #{seccion} #{nombre_cientifico}"
            break
          end

        else
          self.nombre_cientifico = nombre.limpiar
      end
    end

    # Para quitar los espacios adicionales
    self.nombre_cientifico = nombre_cientifico.strip.gsub(/\s+/,' ')
  end

  def pon_nombre_comun_principal(base)
    con_espaniol = false

    # Verifica el nombre en catalogos
    nombres_comunes.each do |nc|
      if !con_espaniol && nc.lengua == 'Español'
        self.nombre_comun_principal = nc.nombre_comun.humanizar
        con_espaniol = true
      elsif !con_espaniol && nc.lengua == 'Inglés'
        self.nombre_comun_principal = nc.nombre_comun.humanizar
      elsif !con_espaniol
        self.nombre_comun_principal = nc.nombre_comun.humanizar
      end
    end

    # Si no tiene nombre comun en catalogos tratare de ponerle uno de NaturaLista
    if nombre_comun_principal.blank?
      id_vista = Bases.id_original_a_id_en_vista(id)
      Bases.conecta_a Rails.env

      begin
        taxon = Especie.find(id_vista)
      rescue
        Bases.conecta_a(base)
        return
      end

      return unless prov = taxon.proveedor
      return unless prov.naturalista_info.present?

      datos = eval(prov.naturalista_info)
      datos = datos.first if datos.is_a?(Array)
      default_name = datos['default_name']

      return unless default_name.present?
      return unless default_name['is_valid']
      return unless default_name['name'].present?

      lexicon = I18n.transliterate(default_name['lexicon']).gsub(' ','_').downcase
      return unless LENGUAS_ACEPTADAS.include?(lexicon)
      nombre_comun_principal = default_name['name']

      Bases.conecta_a(base)
      self.nombre_comun_principal = nombre_comun_principal.humanizar
    end
  end

  def completa_redis?
    if ancestry_ascendente_directo_changed? || nombre_autoridad_changed? || nombre_cientifico_changed?
      json = ''
      id_vista = Bases.id_original_a_id_en_vista(id)
      ruta = Rails.root.join('tools', 'bitacoras', 'redis', id.to_s).to_s
      FileUtils.mkpath(ruta, :mode => 0755) if !File.exists?(ruta)
      f = "#{ruta}/#{Time.now.strftime("%Y%m%d%H%M%S")}_nom_cien.json"
      categoria = I18n.transliterate(categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')

      foto = foto_principal.present? ? "<img src='#{foto_principal}' alt='#{nombre_cientifico}' width='30px' \>" :
          "<img src='/assets/app/iconic_taxa/mammalia-75px.png' alt='#{nombre_cientifico}' width='30px' \>"

      json+= "{\"id\":#{id_vista},"
      json+= "\"term\":\"#{nombre_cientifico}\","
      json+= "\"score\":2,"
      json+= "\"data\":{\"nombre_comun\":\"#{Limpia.cadena(nombre_comun_principal)}\", \"foto\":\"#{Limpia.cadena(foto)}\", \"autoridad\":\"#{Limpia.cadena(nombre_autoridad)}\", \"id\":#{id_vista}}"
      json+= "}\n"

      File.open(f,'a') do |f|
        f.puts json
        system("soulmate add cien_#{categoria} --redis=redis://localhost:6379/0 < #{f}") if File.exists?(f)
      end
    end
  end

  #Este metodo es necesario ya que SQL Server hace un lock en el record a cambiar, se tiene que hacer despues de acabar
  #el trigger de SQL Server y ademas para que sea valido en multi bases, asi como estatico
  def self.completa(id, base, tabla)
    Bases.conecta_a base
    taxon = EspecieBio.find(id)
    #taxon.ancestry_directo
    #taxon.ancestry_obligatorio
    taxon.avoid_ancestry = true
    taxon.save

    Bases.conecta_a Rails.env
    Bases.insert_en_volcado(id, base, tabla)
  end

  def self.actualiza(id, base, tabla)
    Bases.conecta_a base
    taxon = EspecieBio.find(id)
    #taxon.ancestry_directo
    #taxon.ancestry_obligatorio
    taxon.avoid_ancestry = true
    taxon.save

    Bases.conecta_a Rails.env
    Bases.update_en_volcado(id, base, tabla)
  end
end
