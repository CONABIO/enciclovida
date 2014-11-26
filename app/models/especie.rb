class Especie < ActiveRecord::Base

  self.table_name='especies'
  has_one :proveedor
  belongs_to :categoria_taxonomica
  has_many :especies_regiones, :class_name => 'EspecieRegion', :foreign_key => 'especie_id', :dependent => :destroy
  has_many :especies_catalogos, :class_name => 'EspecieCatalogo', :dependent => :destroy
  has_many :nombres_regiones, :class_name => 'NombreRegion', :dependent => :destroy
  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :dependent => :destroy
  has_many :especies_status, :class_name => 'EspecieEstatus', :foreign_key => :especie_id1, :dependent => :destroy
  has_many :especies_bibliografias, :class_name => 'EspecieBibliografia', :dependent => :destroy
  has_many :taxon_photos, :order => 'position ASC NULLS LAST, id ASC', :dependent => :destroy
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

  #Los joins explicitos fueron necesarios ya que por default la sentencia es un RIGHT JOIN
  scope :especies_regiones_join, -> { joins('LEFT JOIN especies_regiones ON especies_regiones.especie_id=especies.id') }
  scope :nombres_comunes_join, -> { joins('LEFT JOIN nombres_regiones ON nombres_regiones.especie_id=especies.id').
      joins('LEFT JOIN nombres_comunes ON nombres_comunes.id=nombres_regiones.nombre_comun_id') }
  scope :region_join, -> { joins('LEFT JOIN regiones ON regiones.id=especies_regiones.region_id') }
  scope :tipo_distribucion_join, -> { joins('LEFT JOIN tipos_distribuciones ON tipos_distribuciones.id=especies_regiones.tipo_distribucion_id') }
  scope :caso_nombre_bibliografia, -> { joins('LEFT JOIN nombres_regiones_bibliografias ON nombres_regiones_bibliografias.especie_id=especie.id').
      joins('LEFT JOIN bibliografias ON bibliografias.id=nombres_regiones_bibliografias.bibliografia_id') }
  scope :catalogos_join, -> { joins('LEFT JOIN especies_catalogos ON especies_catalogos.especie_id=especies.id').
      joins('LEFT JOIN catalogos ON catalogos.id=especies_catalogos.catalogo_id') }
  scope :categoria_taxonomica_join, -> { joins('LEFT JOIN categorias_taxonomicas ON categorias_taxonomicas.id=especies.categoria_taxonomica_id') }
  scope :datos, -> { joins('LEFT JOIN especies_regiones ON especies.id=especies_regiones.especie_id').joins('LEFT JOIN categoria_taxonomica') }

  before_save :ponNombreCientifico

  WillPaginate.per_page = 10
  self.per_page = WillPaginate.per_page

  POR_PAGINA = [10, 20, 50, 100, 200, 500, 1000]
  CON_REGION = [19, 50]
  ESTATUS = [
      [2, 'válido/correcto'],
      [1, 'sinónimo']
  ]

  ESTATUS_SIMBOLO = {
      2 => '',
      1 =>''
  }

  ESTATUS_SIGNIFICADO = {
      2 => 'válido/correcto',
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

  def species_or_lower?(cat=nil)
    SPECIES_OR_LOWER.include?(cat || categoria_taxonomica.nombre_categoria_taxonomica)
  end

  #
  # Fetches associated user-selected FlickrPhotos if they exist, otherwise
  # gets the the first :limit Create Commons-licensed photos tagged with the
  # taxon's scientific name from Flickr.  So this will return a heterogeneous
  # array: part FlickrPhotos, part api responses
  #
  def photos_with_backfill(options = {})
    options[:limit] ||= 9
    chosen_photos = taxon_photos.includes(:photo).order('taxon_photos.position ASC NULLS LAST, taxon_photos.id ASC').limit(options[:limit]).map{|tp| tp.photo}
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

  # Guarda en cache el path del KMZ
  def snib_cache_key
    "snib_#{id}"
  end

  private

  def ponNombreCientifico
    case self.categoria_taxonomica_id
      when 19, 50 #para especies
        generoID=self.ancestry_ascendente_obligatorio.split('/').last
        genero=Especie.find(generoID.to_i).nombre
        self.nombre_cientifico="#{genero} #{self.nombre}"
      when 20, 21, 22, 23, 24, 51, 52, 53, 54, 55 #para subespecies
        generoID=self.ancestry_ascendente_obligatorio.split('/')[5]
        genero=Especie.find(generoID).nombre
        especieID=self.ancestry_ascendente_obligatorio.split('/')[6]
        especie=Especie.find(especieID).nombre
        self.nombre_cientifico="#{genero} #{especie} #{self.nombre}"
      else
        self.nombre_cientifico=self.nombre
    end
  end

end
