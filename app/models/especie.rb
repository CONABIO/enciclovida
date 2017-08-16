class Especie < ActiveRecord::Base
  include CacheServices

  self.table_name='especies'
  self.primary_key='id'

  # Atributos adicionales para poder exportar los datos a excel directo como columnas del modelo
  attr_accessor :x_estatus, :x_naturalista_id, :x_snib_id, :x_snib_reino, :x_categoria_taxonomica,
                :x_naturalista_obs, :x_snib_registros, :x_geoportal_mapa,
                :x_nom, :x_iucn, :x_cites, :x_tipo_distribucion,
                :x_nombres_comunes, :x_nombre_comun_principal, :x_lengua, :x_nombres_comunes_naturalista,
                :x_nombres_comunes_catalogos,
                :x_fotos, :x_foto_principal, :x_square_url, :x_fotos_principales, :x_fotos_totales,
                :x_reino, :x_division, :x_subdivision, :x_clase, :x_subclase, :x_superorden, :x_orden, :x_suborden,
                :x_familia, :x_subfamilia, :x_tribu, :x_subtribu, :x_genero, :x_subgenero, :x_seccion, :x_subseccion,
                :x_serie, :x_subserie, :x_especie, :x_subespecie, :x_variedad, :x_subvariedad, :x_forma, :x_subforma,
                :x_subreino, :x_superphylum, :x_phylum, :x_subphylum, :x_superclase, :x_subterclase, :x_grado, :x_infraclase,
                :x_infraorden, :x_superfamilia, :x_supertribu, :x_parvorden, :x_superseccion, :x_grupo,
                :x_infraphylum, :x_epiclase, :x_cohorte, :x_grupo_especies, :x_raza, :x_estirpe,
                :x_subgrupo, :x_hiporden,
                :x_nombre_autoridad, :x_nombre_autoridad_infraespecie,  # Para que en el excel sea mas facil la consulta
                :x_distancia
  alias_attribute :x_nombre_cientifico, :nombre_cientifico

  has_one :proveedor
  has_one :adicional
  has_many :categorias_conteo, :class_name => 'CategoriaConteo', :foreign_key => 'especie_id', :dependent => :destroy
  belongs_to :categoria_taxonomica
  has_many :especies_regiones, :class_name => 'EspecieRegion', :foreign_key => 'especie_id', :dependent => :destroy
  has_many :especies_catalogos, :class_name => 'EspecieCatalogo', :dependent => :destroy
  has_many :nombres_regiones, :class_name => 'NombreRegion', :dependent => :destroy
  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :dependent => :destroy
  has_many :especies_estatus, :class_name => 'EspecieEstatus', :foreign_key => :especie_id1, :dependent => :destroy
  has_many :especies_bibliografias, :class_name => 'EspecieBibliografia', :dependent => :destroy
  has_many :taxon_photos, :order => 'position ASC, id ASC', :dependent => :destroy
  has_many :photos, :through => :taxon_photos
  has_many :bibliografias, :through => :especies_bibliografias
  has_many :regiones, :through => :nombres_regiones
  has_many :nombres_comunes, :through => :nombres_regiones, :source => :nombre_comun
  has_many :tipos_distribuciones, :through => :especies_regiones, :source => :tipo_distribucion
  has_many :estados_conservacion, :through => :especies_catalogos, :source => :catalogo
  has_many :metadatos_especies, :class_name => 'MetadatoEspecie', :foreign_key => 'especie_id'
  has_many :metadatos, :through => :metadatos_especies#, :source => :metadato
  has_many :usuario_especies, :class_name => 'UsuarioEspecie', :foreign_key => :especie_id
  has_many :usuarios, :through => :usuario_especies, :source => :usuario
  has_many :comentarios, :class_name => 'Comentario', :foreign_key => :especie_id

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
  scope :caso_nombre_comun_y_cientifico, ->(nombre) { where("LOWER(nombre_comun) LIKE LOWER('%#{nombre}%') OR LOWER(nombre_cientifico) LIKE LOWER('%#{nombre}%')
  OR LOWER(nombre_comun_principal) LIKE LOWER('%#{nombre}%')") }

  # Los joins explicitos fueron necesarios ya que por default "joins", es un RIGHT JOIN
  scope :especies_regiones_join, -> { joins('LEFT JOIN especies_regiones ON especies_regiones.especie_id=especies.id') }
  scope :nombres_comunes_join, -> { joins('LEFT JOIN nombres_regiones ON nombres_regiones.especie_id=especies.id').
      joins('LEFT JOIN nombres_comunes ON nombres_comunes.id=nombres_regiones.nombre_comun_id') }
  scope :region_join, -> { joins('LEFT JOIN regiones ON regiones.id=especies_regiones.region_id') }
  scope :tipo_region_join, -> { joins('LEFT JOIN tipos_regiones ON tipos_regiones.id=regiones.tipo_region_id') }
  scope :tipo_distribucion_join, -> { especies_regiones_join.joins('LEFT JOIN tipos_distribuciones ON tipos_distribuciones.id=especies_regiones.tipo_distribucion_id') }
  scope :nombre_bibliografia_join, -> { joins('LEFT JOIN nombres_regiones_bibliografias ON nombres_regiones_bibliografias.especie_id=especies.id').
      joins('LEFT JOIN bibliografias ON bibliografias.id=nombres_regiones_bibliografias.bibliografia_id').
      joins('LEFT JOIN nombres_comunes ON nombres_comunes.id=nombres_regiones_bibliografias.nombre_comun_id')}
  scope :catalogos_join, -> { joins('LEFT JOIN especies_catalogos ON especies_catalogos.especie_id=especies.id').
      joins('LEFT JOIN catalogos ON catalogos.id=especies_catalogos.catalogo_id') }
  scope :categoria_taxonomica_join, -> { joins('LEFT JOIN categorias_taxonomicas ON categorias_taxonomicas.id=especies.categoria_taxonomica_id') }
  scope :adicional_join, -> { joins('LEFT JOIN adicionales ON adicionales.especie_id=especies.id') }
  scope :categoria_conteo_join, -> { joins('LEFT JOIN categorias_conteo ON categorias_conteo.especie_id=especies.id') }
  scope :icono_join, -> { joins('LEFT JOIN iconos ON iconos.id=adicionales.icono_id') }

  # Select basico que contiene los campos a mostrar por ponNombreCientifico
  scope :select_basico, ->(attr_adicionales=[]) { select('especies.id, nombre_cientifico, estatus, nombre_autoridad,
        adicionales.nombre_comun_principal, adicionales.foto_principal,
categoria_taxonomica_id, nombre_categoria_taxonomica, cita_nomenclatural, ancestry_ascendente_directo,
nombres_comunes as nombres_comunes_adicionales' << (attr_adicionales.any? ? ",#{attr_adicionales.join(',')}" : '')) }
  # Select y joins basicos que contiene los campos a mostrar por ponNombreCientifico
  scope :datos_basicos, ->(attr_adicionales=[]) { select_basico(attr_adicionales).categoria_taxonomica_join.adicional_join }
  # Datos sacar los IDs unicos de especies
  scope :datos_count, -> { select('count(DISTINCT especies.id) AS totales').categoria_taxonomica_join.adicional_join}
  #Select para el Checklist (por_arbol)
  scope :datos_arbol_sin_filtros , -> {select("especies.id, nombre_cientifico, ancestry_ascendente_directo,
ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol, categoria_taxonomica_id,
categorias_taxonomicas.nombre_categoria_taxonomica, nombre_autoridad, estatus, nombre_comun_principal,
nombres_comunes as nombres_comunes_adicionales").categoria_taxonomica_join.adicional_join }
  scope :datos_arbol_con_filtros , -> {select("ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol").categoria_taxonomica_join.adicional_join }
  #Selects para construir la taxonomía por cada uno del set de resultados cuando se usca por nombre cientifico en la básica
  scope :datos_arbol_para_json , -> {select("ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol")}
  scope :datos_arbol_para_json_2 , -> {select("especies.id, nombre_cientifico,
ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol, categorias_taxonomicas.nombre_categoria_taxonomica,
nombre_autoridad, estatus").categoria_taxonomica_join }
  #Select para la Subcoordinadora de Evaluación de Ecosistemas ()Ana Victoria Contreras Ruiz Esparza)
  scope :select_evaluacion_eco, -> { select('especies.id, nombre_cientifico, categoria_taxonomica_id, nombre_categoria_taxonomica, catalogo_id') }
  scope :order_por_categoria, ->(orden) { order("CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4) #{orden}") }
  #select para los grupos iconicos en la busqueda avanzada para no realizar varios queries al mismo tiempo
  scope :select_grupos_iconicos, -> {select('especies.id, nombre_cientifico, nombre_comun_principal').adicional_join}


  CON_REGION = [19, 50]

  ESTATUS = [
      [2, 'válido'],
      [1, 'sinónimo'],
      [6, 'No disponible'],
      [9, 'No aplica']
  ]

  ESTATUS_BUSQUEDA = [
      [2, 'válido'],
      [1, 'sinónimo']
  ]

  ESTATUS_VALOR = {
      ESTATUS[0][0] => ESTATUS[0][1],
      ESTATUS[1][0] => ESTATUS[1][1]
  }

  ESTATUS_SIGNIFICADO = {
      2 => 'válido',
      1 =>'sinónimo',
      6 => 'No disponible',
      9 => 'No aplica'
  }

  SPECIES_OR_LOWER = %w(especie subespecie variedad subvariedad forma subforma)
  BAJO_GENERO = %w(género subgénero sección subsección serie subserie)

  # Muestra las fichas de Dalbergias
  DALBERGIAS = %w(Dalbergia_glomerata Dalbergia_calycina Dalbergia_calderonii Dalbergia_congestiflora
Dalbergia_tucurensis Dalbergia_granadillo Dalbergia_longepedunculata Dalbergia_luteola
Dalbergia_melanocardium Dalbergia_modesta Dalbergia_palo-escrito Dalbergia_rhachiflexa
Dalbergia_ruddae Dalbergia_stevensonii Dalbergia_cubilquitzensis)

  # Para sacar los nombres de las categorias de IUCN, NOM, CITES, ambiente y prioritaria, regresa un array
  def nom_cites_iucn_ambiente_prioritaria(ws=false)
    response = []

    especies_catalogos.each do |e|
      cat = e.catalogo

      nom_cites_iucn = cat.nom_cites_iucn(true, ws)
      if nom_cites_iucn.present?
        response << nom_cites_iucn.parameterize
      end

      amb = cat.ambiente
      if amb.present?
        response << amb.parameterize
      end

      prio = cat.prioritaria
      if prio.present?
        response << prio.parameterize
      end
    end  #Fin each

    response.uniq
  end

  def tipo_distribucion
    response = []

    tipos_distribuciones.uniq.each do |distribucion|
      next if distribucion.descripcion.parameterize == 'original'  # Quitamos el tipo de dist. original

      if distribucion.descripcion.parameterize.downcase == 'no-endemica'
        response << I18n.t("tipo_distribucion.#{distribucion.descripcion.parameterize.downcase}.nombre").downcase
      else
        response << distribucion.descripcion.parameterize
      end

    end

    response.uniq
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

  def species_or_lower?
    SPECIES_OR_LOWER.include?(self.try(:nombre_categoria_taxonomica) || categoria_taxonomica.nombre_categoria_taxonomica)
  end

  def apta_con_geodatos?
    CategoriaTaxonomica::CATEGORIAS_GEODATOS.include? categoria_taxonomica.nombre_categoria_taxonomica
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

  # Guarda en cache el path del KMZ
  def snib_cache_key
    "snib_#{id}"
  end

  def completa_blurrily
    FUZZY_NOM_CIEN.put(nombre_cientifico, id)
  end

  def redis(opc={})
    datos = {}
    datos['data'] = {}

    fotos_nombres_servicios if opc[:consumir_servicios]

    # Asigna si viene la peticion de nombre comun
    if nc = opc[:nombre_comun]
      datos['id'] = "#{nc.id}#{id}00000".to_i
      datos['term'] = I18n.transliterate(nc.nombre_comun.limpia)
      datos['data']['nombre_comun'] = nc.nombre_comun.limpia.capitalize
      datos['data']['id'] = id
      datos['data']['lengua'] = nc.lengua

    else  # Asigna si viene la peticion de nombre_cientifico
      datos['id'] = id
      datos['term'] = I18n.transliterate(nombre_cientifico.limpia)
      datos['data']['nombre_comun'] = x_nombre_comun_principal.try(:limpia).try(:capitalize)
      datos['data']['id'] = id
      datos['data']['lengua'] = x_lengua
    end

    datos['data']['foto'] = x_square_url  # Foto square_url
    datos['data']['nombre_cientifico'] = nombre_cientifico.limpia
    datos['data']['estatus'] = Especie::ESTATUS_VALOR[estatus]
    datos['data']['autoridad'] = nombre_autoridad.try(:limpia)

    # Caracteristicas de riesgo y conservacion, ambiente y distribucion
    cons_amb_dist = []
    cons_amb_dist << nom_cites_iucn_ambiente_prioritaria(true)
    cons_amb_dist << tipo_distribucion
    datos['data']['cons_amb_dist'] = cons_amb_dist.flatten

    # Para saber cuantas fotos tiene
    datos['data'][:fotos] = x_fotos_totales

    # Para saber si tiene algun mapa
    if p = proveedor
      datos['data']['geodatos'] = p.geodatos[:cuales]
    end

    datos
  end

  # Pone un nuevo record en redis para el nombre comun (fuera de catalogos) y el nombre cientifico
  def guarda_redis(opc={})
    # Pone en nil las variables para guardar los servicios y no consultarlos de nuevo
    self.x_foto_principal = nil
    self.x_nombre_comun_principal = nil
    self.x_lengua = nil
    self.x_fotos_totales = 0  # Para poner cero si no tiene fotos
    self.x_nombres_comunes_naturalista = nil

    categoria = I18n.transliterate(categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')

    # Guarda en la categoria seleccionada
    loader = Soulmate::Loader.new(categoria)

    # Guarda el redis con todos los nombres cientificos
    loader.add(redis(opc.merge({consumir_servicios: true})))

    # Guarda el redis con todos los nombres comunes
    nombres_comunes.each do |nc|
      loader.add(redis(opc.merge({nombre_comun: nc})))
    end

    # Guarda el redis con los nombres comunes de naturalista diferentes a catalogos
    if x_nombres_comunes_naturalista
      primer_nombre = nil

      x_nombres_comunes_naturalista.each_with_index do |nom, index|
        next if nom['lexicon'] == 'Scientific Names'
        next if x_nombres_comunes_catalogos.present? && x_nombres_comunes_catalogos.include?(I18n.transliterate(nom['name'].downcase))
        primer_nombre = nom['name'] if index == 0
        next if primer_nombre == nom['name'] && index > 0

        if nom['lexicon'].present?
          lengua = I18n.transliterate(nom['lexicon'].downcase.gsub(' ','_'))
        else
          lengua = 'nd'
        end

        nc = NombreComun.new({id: nom['id'], nombre_comun: nom['name'], lengua: I18n.t("lenguas.#{lengua}", default: lengua)})
        loader.add(redis(opc.merge({nombre_comun: nc})))

      end
    end

    puts "\n\nGuardo redis #{id}"
  end

  # Servicio que trae la respuesta de bdi
  def fotos_bdi(opts={})
    bdi = BDIService.new

    if species_or_lower? || categoria_taxonomica.nombre_categoria_taxonomica == 'género'
      bdi.dameFotos(opts.merge({nombre: x_nombre_cientifico, campo: 528}))
    elsif is_root?
      bdi.dameFotos(opts.merge({nombre: x_nombre_cientifico, campo: 15}))
    else
      bdi.dameFotos(opts.merge({nombre: x_nombre_cientifico, campo: 20}))
    end

  end

  # Fotos y nombres comunes de dbi, catalogos y naturalista
  def fotos_nombres_servicios
    ficha_naturalista_por_nombre if !proveedor  # Para encontrar el naturalista_id si no existe el proveedor

    if p = proveedor
      # Fotos de naturalista
      fn = p.fotos_naturalista

      if fn[:estatus] == 'OK'
        self.x_fotos_totales+= fn[:fotos].count

        if fn[:fotos].count > 0
          self.x_square_url = fn[:fotos].first['photo']['square_url']
          self.x_foto_principal = fn[:fotos].first['photo']['medium_url'] || fn[:fotos].first['photo']['large_url']
        end
      end

      # Para guardar los nombres comunes de naturalista y el nombre comun principal
      ncn = p.nombres_comunes_naturalista
      if ncn[:estatus] == 'OK'  # Si naturalista tiene un nombre default, le pongo ese
        ncn[:nombres_comunes].each do |nc|
          if nc['lexicon'] != 'Scientific Names'
            self.x_nombre_comun_principal = nc['name']

            # Asigna la lengua
            lengua = nc['lexicon']
            if lengua.present?
              l = I18n.transliterate(lengua.downcase.gsub(' ','_'))
              self.x_lengua = I18n.t("lenguas.#{l}", default: lengua)
            else
              self.x_lengua = I18n.t("lenguas.nd", default: lengua)
            end

            break  # Es necesario salirse para que no asigne el ultimo

          end  # End lexicon != nombre cientifico
        end  # End each do nombres_comunes

        self.x_nombres_comunes_naturalista = ncn[:nombres_comunes]

      end  # End estatus OK
    end

    # Fotos de bdi
    fb = fotos_bdi
    if fb[:estatus] == 'OK'
      self.x_square_url = fb[:fotos].first.square_url if x_foto_principal.blank? && fb[:fotos].count > 0
      self.x_foto_principal = fb[:fotos].first.best_photo if x_foto_principal.blank? && fb[:fotos].count > 0

      if ultima = fb[:ultima]  # Si tiene ultima obtenemos el numero final, para consultarla
        self.x_fotos_totales+= 25*(ultima-1)
        fbu = fotos_bdi({pagina: ultima})

        if fbu[:estatus] == 'OK'
          self.x_fotos_totales+= fbu[:fotos].count
        end
      else  # Solo era un paginado, las sumo inmediatamente
        self.x_fotos_totales+= fb[:fotos].count
      end
    end

    # Asigno estos nombres comunes ya que los ocupare más adelante
    self.x_nombres_comunes_catalogos = nombres_comunes.map{|nc| I18n.transliterate(nc.nombre_comun.downcase)} if nombres_comunes.length > 0

    # Si no guardo el de naturalista, pongo el default de catalogos
    nombre_comun_principal_catalogos if x_nombre_comun_principal.blank?

    # Para guardar la foto principal para los resultados, es la best_photo
    if a = adicional
      a.foto_principal = x_foto_principal
      a.nombre_comun_principal = x_nombre_comun_principal
      a.save if a.changed?
    else
      Adicional.create({foto_principal: x_foto_principal, nombre_comun_principal: x_nombre_comun_principal, especie_id: id})
    end
  end

  # Es un metodo que no depende del la tabla proveedor, puesto que consulta naturalista sin el ID
  def ficha_naturalista_por_nombre
    return {estatus: 'error', msg: 'No hay resultados'} if existe_cache?('ficha_naturalista')
    escribe_cache('ficha_naturalista', eval(CONFIG.cache.ficha_naturalista)) if Rails.env.production?

    begin
      respuesta = RestClient.get "#{CONFIG.naturalista_url}/taxa/search.json?q=#{URI.escape(nombre_cientifico.limpiar.limpia)}"
      resultados = JSON.parse(respuesta)
    rescue => e
      return {estatus: 'error', msg: e}
    end

    # Nos aseguramos que coincide el nombre
    return {estatus: 'error', msg: 'No hay resultados'} if resultados.count == 0

    resultados.each do |t|
      next unless t['ancestry'].present?
      if t['name'].downcase == nombre_cientifico.downcase
        reino_naturalista = t['ancestry'].split('/')[1].to_i
        next unless reino_naturalista.present?
        reino_enciclovida = is_root? ? id : ancestry_ascendente_directo.split('/').first.to_i

        # Si coincide el reino con animalia, plantas u hongos, OJO quitar esto en la centralizacion
        if (reino_naturalista == 1 && reino_enciclovida == 1000001) || (reino_naturalista == 47126 && reino_enciclovida == 6000002) || (reino_naturalista == 47170 && reino_enciclovida == 3000004)

          if p = proveedor
            p.naturalista_id = t['id']
            p.save
          else
            self.proveedor = Proveedor.create({naturalista_id: t['id'], especie_id: id})
          end

          return {estatus: 'OK', ficha: t}
        end

      end  # End nombre cientifico
    end  # End resultados

    return {estatus: 'error', msg: 'No hubo coincidencias con los resultados del servicio'}
  end

  # El nombre predeterminado de catalogos y la lengua
  def nombre_comun_principal_catalogos
    con_espaniol = false

    nombres_comunes.each do |nc|
      if !con_espaniol && nc.lengua == 'Español'
        self.x_nombre_comun_principal = nc.nombre_comun
        self.x_lengua = nc.lengua
        con_espaniol = true
      elsif !con_espaniol && nc.lengua == 'Inglés'
        self.x_nombre_comun_principal = nc.nombre_comun
        self.x_lengua = nc.lengua
      elsif !con_espaniol
        self.x_nombre_comun_principal = nc.nombre_comun
        self.x_lengua = nc.lengua
      end
    end  # End nombres_comunes
  end

  def nombres_comunes_todos
    # El orden de las lenguas, ya para que no se enojen!!!
    lenguas_primero = ['Español', 'Náhuatl', 'Maya', 'Otomí', 'Huasteco', 'Purépecha', 'Huichol', 'Zapoteco', 'Totonaco', 'Mixteco', 'Mazahua', 'Tepehuano', 'Inglés']
    lenguas_ultimo = ['Japonés', 'Chino tradicional', 'ND']

    # Los nombres comunes de catalogos en hash con la lengua
    ncc = nombres_comunes.map {|nc| {nc.lengua => nc.nombre_comun.capitalize}}

    # Para los nombres comunes de naturalista
    if p = proveedor
      ncnat = p.nombres_comunes_naturalista
    else
      ncnat = {estatus: 'error'}
    end

    if ncnat[:estatus] == 'OK'
      ncn = ncnat[:nombres_comunes].map do |nc|
        next if nc['lexicon'].present? && nc['lexicon'] == 'Scientific Names'

        # Asigna la lengua
        lengua = nc['lexicon']

        if lengua.present?
          l = I18n.transliterate(lengua).parameterize.downcase.gsub('-','_')
        else
          l = 'nd'
        end

        # Los nombres comunes de naturalista en hash con la lengua
        {I18n.t("lenguas.#{l}", default: lengua.capitalize) => nc['name'].capitalize}
      end
    else
      ncn = []
    end

    # PAra el orden de las lenguas
    nombres = (ncc + ncn).uniq.compact
    nombres_inicio = []
    nombres_mitad = []
    nombres_final = []

    nombres.each do |nombre|
      lengua = nombre.keys.first  # Ya que es un hash

      if lenguas_primero.include?(lengua)
        index = lenguas_primero.index(lengua)

        # Crea el arreglo dentro del hash lengua para agrupar nombres de la misma lengua
        if nombres_inicio[index].nil?
          nombres_inicio[index] = {}
          nombres_inicio[index][lengua] = []
        end

        nombres_inicio[index][lengua] << nombre[lengua]

      elsif lenguas_ultimo.include?(lengua)
        index = lenguas_ultimo.index(lengua)

        # Crea el arreglo dentro del hash lengua para agrupar nombres de la misma lengua
        if nombres_final[index].nil?
          nombres_final[index] = {}
          nombres_final[index][lengua] = []
        end

        nombres_final[index][lengua] << nombre[lengua]

      else
        encontro_lengua = false
        nombres_mitad.each do |nombre_mitad|
          lengua_mitad = nombre_mitad.keys.first

          # Quiere decir que ya habia metido esa lengua
          if lengua_mitad == lengua
            nombre_mitad[lengua] << nombre[lengua]
            encontro_lengua = true
            break
          end
        end

        next if encontro_lengua

        # Si llego a este punto, entonces creamos el hash
        nombres_mitad << {lengua => [nombre[lengua]]}
      end
    end

    # Los uno para obtener los nombres unidos
    (nombres_inicio + nombres_mitad + nombres_final).compact
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

  # Pone el grupo iconico en la tabla adicionales
  def crea_con_grupo_iconico(id)
    ad = Adicional.new
    ad.especie_id = self.id
    ad.icono_id = id
    ad
  end

  # Pone la foto principal en la tabla adicionales
  def asigna_foto
    # Pone la primera foto que encuentre con NaturaLista, de lo contrario una de CONABIO
    foto_p = ''

    fotos = photos.where("photos.type != 'ConabioPhoto'")

    if fotos.any?
      fotos.each do |f|
        if f.square_url.present?
          foto_p = f.square_url
          break
        end
      end
    else
      photos.where("photos.type = 'ConabioPhoto'").each do |f|
        if f.square_url.present?
          foto_p = f.square_url
          break
        end
      end
    end

    return {:cambio => false} unless foto_p.present?

    if adicional
      adicional.foto_principal = foto_p
    else
      ad = crea_con_foto(foto_p)
      return {:cambio => ad.foto_principal.present?, :adicional => ad}
    end

    {:cambio => adicional.foto_principal_changed?, :adicional => adicional}
  end

  # Pone la foto principal en la tabla adicionales
  def crea_con_foto(foto_principal)
    ad = Adicional.new
    ad.especie_id = id
    ad.foto_principal = foto_principal
    ad
  end

  # Metodo para retraer el nombre comun principal ya sea que venga de un join con adicionales o lo construye
  def nom_com_prin(primera_mayus = true)
    if self.try(:taxon_icono).present?
      if self.try(:nombre_comun_principal).present?
        primera_mayus ? self.nombre_comun_principal.capitalize : self.nombre_comun_principal
      else
        ''
      end
    else

      begin
        if nombre_comun_principal.present?
          primera_mayus ? nombre_comun_principal.capitalize : nombre_comun_principal
        else
          ''
        end
      rescue
        if ad=adicional
          if ad.nombre_comun_principal.present?
            primera_mayus ? ad.nombre_comun_principal.capitalize : ad.nombre_comun_principal
          else
            ''
          end
        else
          ''
        end
      end
    end
  end

  # Devuelve un array de todos los nombres comunes, incluyendo el nombre_principal
  def todos_los_nombres_comunes
    nombres = nombres_comunes.map {|nc|
      # Este condicional fue necesario para poder agrupar los nombres si la lengua es nula
      if nc.lengua.present?
        {nc.lengua => nc.nombre_comun.capitalize}
      else
        {'ND' => nc.nombre_comun.capitalize}
      end
    }.uniq

    agrupa_nombres = nombres.reduce({}) {|h, pairs| pairs.each {|k, v| (h[k] ||= []) << v}; h}

    # Añade el nombre comun principal
    if a = adicional
      # Le asigno 'A' para que sea el primer nombre en aparecer cuando se ordenan
      agrupa_nombres['A'] = [a.nombre_comun_principal] if a.nombre_comun_principal.present?
    end

    if agrupa_nombres.present? && agrupa_nombres.any?
      agrupa_nombres.sort.to_h
    else
      {}
    end

  end

  # Pone el nombre comun que haya coincidido, de acuerdo a la lista,
  # nombre es la busqueda que realizo
  def cual_nombre_comun_coincidio(nombre, fuzzy_match=false)
    # nombres_comunes_adicionales es un alias a nombres_comunes de adicionales
    return self.x_nombre_comun_principal = nil unless nombres_comunes_adicionales.present?
    nombres = JSON.parse(nombres_comunes_adicionales).values.flatten
    return self.x_nombre_comun_principal = nil unless nombres.any?

    # Para hacer la comparacion en minisculas y sin acentos
    nombre_limpio = I18n.transliterate(nombre.limpia).downcase

    nombres.each do |n|
      n_limipio = I18n.transliterate(n.limpia).downcase

      if fuzzy_match
        distancia = Levenshtein.distance(nombre_limpio, n_limipio)

        if distancia < 3
          return self.x_nombre_comun_principal = n
        end
      else
        if n_limipio.include?(nombre_limpio)
          return self.x_nombre_comun_principal = n
        end
      end
    end
  end

  # Asigna todas las categorias hacia arriba de un taxon, para poder acceder a el mas facil
  def asigna_categorias

    path.select('nombre, nombre_categoria_taxonomica').categoria_taxonomica_join.each do |ancestro|
      categoria = 'x_' << I18n.transliterate(ancestro.nombre_categoria_taxonomica).gsub(' ','_').downcase
      next unless Lista::COLUMNAS_CATEGORIAS.include?(categoria)
      eval("self.#{categoria} = ancestro.nombre")  # Asigna el nombre del ancestro si es que coincidio con la categoria

      # Asigna autoridades para el excel
      if categoria == 'x_especie'
        self.x_nombre_autoridad = nombre_autoridad
      end

      # Para las infraespecies
      infraespecies = CategoriaTaxonomica::CATEGORIAS_INFRAESPECIES.map{|c| "x_#{c}"}
      if infraespecies.include?(categoria)
        self.x_nombre_autoridad_infraespecie = nombre_autoridad
      end
    end

    # Asigna la categoria taxonomica
    self.x_categoria_taxonomica = categoria_taxonomica.nombre_categoria_taxonomica
  end

end
