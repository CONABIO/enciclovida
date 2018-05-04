class Especie < ActiveRecord::Base

  establish_connection(:catalogos)
  self.table_name = 'catalogocentralizado.Nombre'
  self.primary_key = 'IdNombre'

  include CacheServices

  # Los alias con las tablas de catalogos
  alias_attribute :id, :IdNombre
  alias_attribute :categoria_taxonomica_id, :IdCategoriaTaxonomica
  alias_attribute :id_nombre_ascendente, :IdNombreAscendente
  alias_attribute :id_ascend_obligatorio, :IdAscendObligatorio
  alias_attribute :nombre, :Nombre
  alias_attribute :estatus, :Estatus
  alias_attribute :fuente, :Fuente
  alias_attribute :nombre_autoridad, :NombreAutoridad
  alias_attribute :numero_filogenetico, :NumeroFilogenetico
  alias_attribute :cita_nomenclatural, :CitaNomenclatural
  alias_attribute :sist_clas_cat_dicc, :SistClasCatDicc
  alias_attribute :anotacion, :Anotacion
  alias_attribute :ancestry_ascendente_directo, :Ascendentes
  alias_attribute :ancestry_ascendente_obligatorio, :AscendentesObligatorios
  alias_attribute :nombre_cientifico, :NombreCompleto
  alias_attribute :created_at, :FechaCaptura
  alias_attribute :updated_at, :FechaModificacion

  # Atributos adicionales para poder exportar los datos a excel directo como columnas del modelo
  attr_accessor :x_estatus, :x_naturalista_id, :x_snib_id, :x_snib_reino, :x_categoria_taxonomica,
                :x_naturalista_obs, :x_snib_registros, :x_geoportal_mapa,
                :x_nom, :x_iucn, :x_cites, :x_tipo_distribucion,
                :x_nombres_comunes, :x_nombre_comun_principal, :x_lengua, :x_nombres_comunes_naturalista,
                :x_nombres_comunes_catalogos,
                :x_fotos, :x_foto_principal, :x_square_url, :x_fotos_principales, :x_fotos_totales,
                :x_reino, :x_division, :x_subdivision, :x_clase, :x_subclase, :x_superorden, :x_orden, :x_suborden,
                :x_familia, :x_subfamilia, :x_epifamilia, :x_tribu, :x_subtribu, :x_genero, :x_subgenero, :x_seccion, :x_subseccion,
                :x_serie, :x_subserie, :x_especie, :x_subespecie, :x_variedad, :x_subvariedad, :x_forma, :x_subforma,
                :x_subreino, :x_superphylum, :x_phylum, :x_subphylum, :x_superclase, :x_subterclase, :x_grado, :x_infraclase,
                :x_infraorden, :x_superfamilia, :x_supertribu, :x_parvorden, :x_superseccion, :x_grupo,
                :x_infraphylum, :x_epiclase, :x_supercohorte, :x_cohorte, :x_grupo_especies, :x_raza, :x_estirpe,
                :x_subgrupo, :x_hiporden, :x_infraserie,
                :x_nombre_autoridad, :x_nombre_autoridad_infraespecie, :x_suprafamilia  # Para que en el excel sea mas facil la consulta
  :x_distancia
  alias_attribute :x_nombre_cientifico, :nombre_cientifico
  attr_accessor :e_geodata, :e_nombre_comun_principal, :e_foto_principal, :e_nombres_comunes, :e_categoria_taxonomica,
                :e_tipo_distribucion, :e_estado_conservacion, :e_bibliografia, :e_fotos  # Atributos para la respuesta en json

  attr_accessor :foto_principal

  has_one :proveedor
  has_one :adicional
  has_one :categoria_conteo

  belongs_to :categoria_taxonomica, :foreign_key => attribute_alias(:categoria_taxonomica_id)

  has_many :nombres_regiones, :class_name => 'NombreRegion', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  has_many :nombres_comunes, :through => :nombres_regiones, :source => :nombre_comun

  has_many :especies_regiones, :class_name => 'EspecieRegion', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  has_many :tipos_distribuciones, :through => :especies_regiones, :source => :tipo_distribucion
  has_many :regiones, :through => :especies_regiones, :source => :region

  has_many :especies_catalogos, :class_name => 'EspecieCatalogo', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  has_many :catalogos, :through => :especies_catalogos, :source => :catalogo

  has_many :especies_estatus, :class_name => 'EspecieEstatus', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  has_many :estatuses, :through => :especies_estatus, :source => :estatus

  has_many :especie_bibliografias, :class_name => 'EspecieBibliografia', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  has_many :bibliografias, :through => :especie_bibliografias, :source => :bibliografia

  has_many :especie_estadisticas, :class_name => 'EspecieEstadistica', :dependent => :destroy
  has_many :estadisticas, :through => :especie_estadisticas, :source => :estadistica



  has_many :categorias_conteo, :class_name => 'CategoriaConteo', :foreign_key => attribute_alias(:especie_id), :dependent => :destroy
  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :dependent => :destroy

  has_many :usuario_especies, :class_name => 'UsuarioEspecie', :foreign_key => :especie_id
  has_many :usuarios, :through => :usuario_especies, :source => :usuario
  has_many :comentarios, :class_name => 'Comentario', :foreign_key => :especie_id


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
  scope :caso_nombre_comun_y_cientifico, ->(nombre) { where("LOWER(#{attribute_alias(:nombre_cientifico)}) LIKE LOWER('%#{nombre}%')
  OR LOWER(#{:nombres_comunes}) LIKE LOWER('%#{nombre}%')") }

  # Select y joins basicos que contiene los campos a mostrar por ponNombreCientifico
  scope :datos_basicos, ->(attr_adicionales=[]) { select_basico(attr_adicionales).categoria_taxonomica_join.adicional_join }
  #Select para el Checklist (por_arbol)
  scope :datos_arbol_sin_filtros , -> {select("especies.id, nombre_cientifico, ancestry_ascendente_directo,
ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol, categoria_taxonomica_id,
categorias_taxonomicas.nombre_categoria_taxonomica, nombre_autoridad, estatus, nombre_comun_principal,
nombres_comunes as nombres_comunes_adicionales").categoria_taxonomica_join.adicional_join }
  scope :datos_arbol_con_filtros , -> { select("CONCAT(#{attribute_alias(:ancestry_ascendente_directo)}, '/', #{attribute_alias(:id)} AS arbol") }
  #Selects para construir la taxonomía por cada uno del set de resultados cuando se usca por nombre cientifico en la básica
  scope :datos_arbol_para_json , -> {select("ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol")}
  scope :datos_arbol_para_json_2 , -> {select("especies.id, nombre_cientifico,
ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol, categorias_taxonomicas.nombre_categoria_taxonomica,
nombre_autoridad, estatus").categoria_taxonomica_join }
  #Select para la Subcoordinadora de Evaluación de Ecosistemas ()Ana Victoria Contreras Ruiz Esparza)
  scope :select_evaluacion_eco, -> { select('especies.id, nombre_cientifico, categoria_taxonomica_id, nombre_categoria_taxonomica, catalogo_id') }
  scope :order_por_categoria, ->(orden) { order("CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4) #{orden}") }


  # Select basico que contiene los campos a mostrar por ponNombreCientifico
  scope :select_basico, ->(attr_adicionales=[]) { select(:id, :nombre_cientifico, :estatus, :nombre_autoridad, :categoria_taxonomica_id, :cita_nomenclatural, :ancestry_ascendente_directo, "nombre_comun_principal, foto_principal, nombres_comunes as nombres_comunes_adicionales" << (attr_adicionales.any? ? ",#{attr_adicionales.join(',')}" : '')).select_categoria_taxonomica }
  # Select para nombre de la categoria y niveles
  scope :select_categoria_taxonomica, -> { select("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} AS nombre_categoria_taxonomica, #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)} AS nivel1, #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel2)} AS nivel2, #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)} AS nivel3, #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)} AS nivel4") }
  #select para los grupos iconicos en la busqueda avanzada para no realizar varios queries al mismo tiempo
  scope :select_grupos_iconicos, -> { select(:id, :nombre_cientifico, :nombre_comun_principal).left_joins(:adicional) }
  # Select para agurpar el los niveles de categoria taxonomica
  scope :select_nivel_categoria, -> { select("CONCAT(#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel2)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}) AS nivel_categoria") }
  # Scope para saber que taxones inferiores desplegar de acuerdo a la categoria en la busqueda vanzada
  scope :nivel_categoria, ->(nivel, categoria) { where("CONCAT(#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel2)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}) #{nivel} '#{categoria}'") }
  # Para que regrese las especies
  scope :solo_especies, -> { where("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)}=? AND #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)}=? AND #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}=?", 7,0,0).left_joins(:categoria_taxonomica) }
  # Para que regrese las especies e inferiores
  scope :especies_e_inferiores, -> { where("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)}=? AND #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)}>?", 7,0).left_joins(:categoria_taxonomica) }
  # Scope para cargar el arbol nodo D3 en la ficha de la espcie
  scope :arbol_nodo_select, -> { Especie.select_basico(['conteo', "#{CategoriaTaxonomica.attribute_alias(:nivel1)} AS nivel1", "#{CategoriaTaxonomica.attribute_alias(:nivel2)} AS nivel2"]).left_joins(:adicional, :categoria_taxonomica, :especie_estadisticas).where('estadistica_id=?',22).where(estatus: 2).where("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)}=? AND #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}=?",0,0) }
  # Scope para cargar el arbol nodo inical en la ficha de la especie
  scope :arbol_nodo_inicial, ->(taxon) { arbol_nodo_select.where(id: taxon.path_ids).order("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)}") }
  # Scope para cargar las hojas del arbol nodo inical en la ficha de la especie
  scope :arbol_nodo_hojas, ->(taxon) { arbol_nodo_select.where("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)}=?",taxon.categoria_taxonomica.nivel1+1).where("#{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%,?,%'", taxon.id).order(:nombre_cientifico) }
  # Scope para cargar el arbol identado en la ficha de la espcie
  scope :arbol_identado_select, -> { Especie.select_basico(['conteo']).select_nivel_categoria.left_joins(:adicional, :categoria_taxonomica, :especie_estadisticas).where("estadistica_id=?",3) }
  # Scope para cargar el arbol identado inical en la ficha de la especie
  scope :arbol_identado_inicial, ->(taxon) { arbol_identado_select.where(id: taxon.path_ids).order('nivel_categoria ASC') }
  # Scope para cargar las hojas del arbol identado inical en la ficha de la especie
  scope :arbol_identado_hojas, ->(taxon) { arbol_identado_select.where(id_nombre_ascendente: taxon.id).where.not(id: taxon.id).order(:nombre_cientifico) }
  # Query que saca los ancestros, nombres cientificos y sus categorias taxonomicas correspondientes
  scope :asigna_info_ancestros, -> { path.select("#{Especie.attribute_alias(:nombre)}, #{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)}").left_joins(:categoria_taxonomica) }

  # Scopes y metodos para ancestry, TODO: ponerlo en una gema

  # REVISADO: Para ver si un taxon es root
  def is_root?
    return false unless ancestry_ascendente_directo.present?
    ancestros = ancestry_ascendente_directo.split(',').map{|a| a if a.present?}.compact
    return false unless ancestros.any?

    ancestros.count == 1 ? true : false
  end

  # REVISADO: Devuelve el taxon root con active record
  def root
    if is_root?
      self
    else
      return Especie.none unless ancestry_ascendente_directo.present?
      ancestros = ancestry_ascendente_directo.split(',').map{|a| a.to_i if a.present?}.compact
      return Especie.none unless ancestros.any?

      Especie.find(ancestros.first)
    end
  end

  # REVISADO: Regresa el id root
  def root_id
    if is_root?
      id
    else
      root.id
    end
  end

  # REVISADO: Devuelve un array de los ancestros y el taxon en cuestion
  def path_ids
    ancestry_ascendente_directo.split(',').map{|a| a.to_i if a.present?}.compact
  end

  # REVISADO: Devuelve el active record de los ancestros y el taxon en cuestion
  def path
    Especie.where(id: path_ids)
  end

  # REVISADO: Devuelve los descendentes en un array
  def descendant_ids
    descendants.map(&:id)
  end

  # REVISADO: Devuelve los descendentes como active record
  def descendants
    Especie.where("#{Especie.attribute_alias(:ancestry_ascendente_directo)} LIKE '%,?,%'", id).where.not(id: id)
  end

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
      1 => 'sinónimo',
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

  # REVISADO: Regresa el numero de especies
  def cuantas_especies(opc = {})
    scope = descendants.solo_especies
    scope = scope.where(estatus: 2) if opc[:validas]
    scope.count
  end

  # REVISADO: Regresa el numero de especies e inferiores
  def cuantas_especies_e_inferiores(opc = {})
    scope = descendants.especies_e_inferiores
    scope = scope.where(estatus: 2) if opc[:validas]
    scope.count
  end

  # REVISADO: Pone el conteo de las especies o inferiores de un taxon en la tabla estadisticas
  def cuantas_especies_inferiores(opc = {})
    return unless opc[:estadistica_id].present?
    puts "\n\nGuardo estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]} - #{id} ..."
    escribe_cache("estadisticas_cuantas_especies_inferiores_#{opc[:estadistica_id]}", eval(CONFIG.cache.estadisticas.cuantas_especies_inferiores)) if Rails.env.production?

    conteo = case opc[:estadistica_id]
               when 2, 22
                 cuantas_especies(opc)
               when 3, 23
                 cuantas_especies_e_inferiores(opc)
               else
                 false
             end

    return unless conteo

    if estadistica = especie_estadisticas.where(estadistica_id: opc[:estadistica_id]).first
      estadistica.conteo = conteo
      estadistica.save if estadistica.changed?
      return
    end

    # Quiere decir que no existia la estadistica
    estadistica = especie_estadisticas.new
    estadistica.estadistica_id = opc[:estadistica_id]
    estadistica.conteo = conteo
    estadistica.save
  end

  # REVISADO: Suma la visita de una ficha en la tabla estadisticas
  def suma_visita
    puts "\n\nGuardo conteo de visitas #{id} ..."

    if estadistica = especie_estadisticas.where(estadistica_id: 1).first
      estadistica.conteo+= 1
      estadistica.save
      return
    end

    # Quiere decir que no existia la estadistica
    estadistica = especie_estadisticas.new
    estadistica.estadistica_id = 1
    estadistica.conteo = 1
    estadistica.save
  end

  def arbol_nodo_hash(opts={})
    children_hash = {}

    case nivel1
      when 7
        children_hash[:color] = '#748c17';
      when 1
        children_hash[:color] = '#c27113'
      else
        children_hash[:color] = '#C6DBEF'
    end

    radius_min_size = opts[:radius_size] || 8
    radius_size = radius_min_size
    children_hash[:radius_size] = radius_size

    especies_o_inferiores = conteo.present? ? conteo : 0
    children_hash[:especies_inferiores_conteo] = especies_o_inferiores

    # URL para ver las especies o inferiores
    nivel_especie = "7#{nivel2}00"
    url = "/busquedas/resultados?id=#{id}&busqueda=avanzada&por_pagina=50&nivel=%3D&cat=#{nivel_especie}&estatus[]=2"
    children_hash[:especies_inferiores_url] = url

    #  Radio de los nodos para un mejor manejo hacia D3
    if especies_o_inferiores > 0

      #  Radios varian de 60 a 40
      if especies_o_inferiores >= 10000
        size_per_radium_unit = (especies_o_inferiores-10000)/20
        radius_size = ((especies_o_inferiores-10000)/size_per_radium_unit) + 40

      elsif especies_o_inferiores >= 1000 && especies_o_inferiores <= 9999  # Radios varian de 40 a 30
        radius_per_range = ((especies_o_inferiores)*10)/9999
        radius_size = radius_per_range + 30

      elsif especies_o_inferiores >= 100 && especies_o_inferiores <= 999  # Radios varian de 30 a 20
        radius_per_range = ((especies_o_inferiores)*10)/999
        radius_size = radius_per_range + 20

      elsif especies_o_inferiores >= 10 && especies_o_inferiores <= 99  # Radios varian de 20 a 13

        radius_per_range = ((especies_o_inferiores)*7)/99
        radius_size = radius_per_range + 13

      elsif especies_o_inferiores >= 1 && especies_o_inferiores <= 9  # Radios varian de 13 a 8

        radius_per_range = ((especies_o_inferiores)*5)/9
        radius_size = radius_per_range + radius_min_size

      end  # End if especies_inferiores_conteo > 0

      children_hash[:radius_size] = radius_size
    end

    children_hash[:especie_id] = id
    children_hash[:nombre_cientifico] = nombre_cientifico
    children_hash[:nombre_comun] = nombre_comun_principal.try(:capitalize)

    # Pone la abreviacion de la categoria taxonomica
    cat = nombre_categoria_taxonomica.estandariza
    abreviacion_categoria = CategoriaTaxonomica::ABREVIACIONES[cat.to_sym].present? ? CategoriaTaxonomica::ABREVIACIONES[cat.to_sym] : ''
    children_hash[:abreviacion_categoria] = abreviacion_categoria
    children_hash
  end

  # REVISADO: Para sacar los nombres de las categorias de IUCN, NOM, CITES, ambiente y prioritaria, regresa un array de hashes
  def nom_cites_iucn_ambiente_prioritaria(opc={})
    response = []

    response << {'NOM-059-SEMARNAT 2010' => catalogos.nom.map(&:descripcion).uniq}

    if opc[:iucn_ws]
      iucn_ws = IUCNService.new.dameRiesgo(:nombre => nombre_cientifico, id: id)

      if iucn_ws.present?
        response << {'IUCN Red List of Threatened Species 2017-1' => [iucn_ws]}
      else
        response << {'IUCN Red List of Threatened Species 2017-1' => catalogos.iucn.map(&:descripcion).uniq}
      end

    else
      response << {'IUCN Red List of Threatened Species 2017-1' => catalogos.iucn.map(&:descripcion).uniq}
    end

    response << {'CITES 2016' => catalogos.cites.map(&:descripcion)}
    response << {'Prioritarias DOF 2014' => catalogos.prioritarias.map(&:descripcion)}
    response << {'Tipo de ambiente' => catalogos.ambientes.map(&:descripcion)}
    response
  end

  # REVISADO: Devuelve el tipo de distribución para colocar en la simbologia del show de especies
  def tipo_distribucion(opc={})
    response = []

    if opc[:tab_catalogos]
      tipos_distribuciones.uniq.each do |distribucion|
        response << distribucion.descripcion
      end
    else
      tipos_distribuciones.distribuciones_vista_general.uniq.each do |distribucion|
        response << distribucion.descripcion
      end
    end

    {'Tipo de distribución' => response}
  end

  def species_or_lower?
    SPECIES_OR_LOWER.include?(self.try(:nombre_categoria_taxonomica) || categoria_taxonomica.nombre_categoria_taxonomica)
  end

  # REVISADO: Regresa si un taxon es especie o inferior o genero
  def especie_o_inferior?(opc = {})

    begin  # En caso que ya exista el join con categoria taxonomica
      if opc[:con_genero]
        return true if nivel1 == 7 || (nivel1 == 6 && nivel3 == 0 && nivel4 == 0)
      else
        return true if nivel1 == 7
      end
    rescue
      if cat = categoria_taxonomica
        if opc[:con_genero]
          return true if cat.nivel1 == 7 || (cat.nivel1 == 6 && cat.nivel3 == 0 && cat.nivel4 == 0)
        else
          return true if cat.nivel1 == 7
        end
      end
    end

    false
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
    datos[:data] = {}

    fotos_nombres_servicios if opc[:consumir_servicios]
    visitas = especie_estadisticas.visitas

    # Asigna si viene la peticion de nombre comun
    if nc = opc[:nombre_comun]
      datos[:id] = "#{nc.id}#{id}00000".to_i
      datos[:term] = I18n.transliterate(nc.nombre_comun.limpia)
      datos[:data][:nombre_comun] = nc.nombre_comun.limpia.capitalize
      datos[:data][:id] = id
      datos[:data][:lengua] = nc.lengua

      # Para el score dependiendo la lengua
      lengua = nc.lengua.estandariza
      index = Adicional:: LENGUAS_ACEPTADAS.reverse.index(lengua) || 0
      datos[:score] = index*visitas

    else  # Asigna si viene la peticion de nombre_cientifico
      datos[:id] = id
      datos[:term] = I18n.transliterate(nombre_cientifico.limpia)
      datos[:data][:nombre_comun] = x_nombre_comun_principal.try(:limpia).try(:capitalize)
      datos[:data][:id] = id
      datos[:data][:lengua] = x_lengua
      datos[:score] = Adicional::LENGUAS_ACEPTADAS.length*visitas
    end

    datos[:data][:foto] = x_square_url  # Foto square_url
    datos[:data][:nombre_cientifico] = nombre_cientifico.limpia
    datos[:data][:estatus] = Especie::ESTATUS_VALOR[estatus]
    datos[:data][:autoridad] = nombre_autoridad.try(:limpia)

    # Caracteristicas de riesgo y conservacion, ambiente y distribucion
    cons_amb_dist = {}
    caracteristicas = nom_cites_iucn_ambiente_prioritaria(iucn_ws: true) << tipo_distribucion

    caracteristicas.reduce({}, :merge).each do |nombre, valores|
      next unless valores.any?

      valores.each do |valor|
        cons_amb_dist[valor.estandariza] = valor
      end
    end

    datos[:data][:cons_amb_dist] = cons_amb_dist

    # Para saber cuantas fotos tiene
    datos[:data][:fotos] = x_fotos_totales

    # Para saber si tiene algun mapa
    if p = proveedor
      datos[:data][:geodatos] = p.geodatos[:cuales]
    end

    datos.stringify_keys
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

    # Guarda el redis con todos los nombres comunes de catalogos
    nombres_comunes.each do |nc|
      loader.add(redis(opc.merge({nombre_comun: nc})))
    end

    # Guarda el redis con los nombres comunes de naturalista y diferentes a catalogos
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

  # REVISADO: Servicio que trae la respuesta de bdi
  def fotos_bdi(opts={})
    bdi = BDIService.new

    if especie_o_inferior?({con_genero: true})
      bdi.dameFotos(opts.merge({taxon: self, campo: 528}))
    elsif is_root?
      bdi.dameFotos(opts.merge({taxon: self, campo: 15}))
    else
      bdi.dameFotos(opts.merge({taxon: self, campo: 20}))
    end
  end

  # Fotos y nombres comunes de dbi, catalogos y naturalista
  def fotos_nombres_servicios
    ficha_naturalista_por_nombre if !proveedor  # Para encontrar el naturalista_id si no existe el proveedor

    if p = proveedor
      fn = p.fotos_naturalista

      if fn[:estatus]
        self.x_fotos_totales+= fn[:fotos].count

        if fn[:fotos].count > 0
          self.x_square_url = fn[:fotos].first['photo']['square_url']
          self.x_foto_principal = fn[:fotos].first['photo']['medium_url'] || fn[:fotos].first['photo']['large_url']
        end
      end

      # Para guardar los nombres comunes de naturalista y el nombre comun principal
      ncn = p.nombres_comunes_naturalista
      if ncn[:estatus]  # Si naturalista tiene un nombre default, le pongo ese
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
    if fb[:estatus]
      self.x_square_url = fb[:fotos].first.square_url if x_foto_principal.blank? && fb[:fotos].count > 0
      self.x_foto_principal = fb[:fotos].first.best_photo if x_foto_principal.blank? && fb[:fotos].count > 0

      if ultima = fb[:ultima]  # Si tiene ultima obtenemos el numero final, para consultarla
        self.x_fotos_totales+= 25*(ultima-1)
        fbu = fotos_bdi({pagina: ultima})

        if fbu[:estatus]
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
    return {estatus: false, msg: 'No hay resultados'} if existe_cache?('ficha_naturalista')
    escribe_cache('ficha_naturalista', eval(CONFIG.cache.ficha_naturalista)) if Rails.env.production?

    begin
      respuesta = RestClient.get "#{CONFIG.naturalista_url}/taxa/search.json?q=#{URI.escape(nombre_cientifico.limpia_ws)}"
      resultados = JSON.parse(respuesta)
    rescue => e
      return {estatus: false, msg: e}
    end

    # Nos aseguramos que coincide el nombre
    return {estatus: false, msg: 'No hay resultados'} if resultados.count == 0

    resultados.each do |t|
      next unless t['ancestry'].present?
      if t['name'].downcase == nombre_cientifico.limpia_ws.downcase
        reino_naturalista = t['ancestry'].split('/')[1].to_i
        next unless reino_naturalista.present?
        reino_enciclovida = root_id

        # Me aseguro que el reino coincida
        if (reino_naturalista == reino_enciclovida) || (reino_naturalista == 47126 && reino_enciclovida == 2) || (reino_naturalista == 47170 && reino_enciclovida == 4) || (reino_naturalista == 47686 && reino_enciclovida == 5)

          if p = proveedor
            p.naturalista_id = t['id']
            p.save
          else
            self.proveedor = Proveedor.create({naturalista_id: t['id'], especie_id: id})
          end

          return {estatus: true, ficha: t}
        end

      end  # End nombre cientifico
    end  # End resultados

    return {estatus: false, msg: 'No hubo coincidencias con los resultados del servicio'}
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
    lenguas_primero = ['Español', 'Español México', 'Náhuatl', 'Maya', 'Otomí', 'Huasteco', 'Purépecha', 'Huichol', 'Zapoteco', 'Totonaco', 'Mixteco', 'Mazahua', 'Tepehuano', 'Inglés']
    lenguas_ultimo = ['Chino tradicional', 'Ruso', 'Japonés', 'Coreano', 'Hebreo', 'AOU 4-Letter Codes', 'Vermont Flora Codes', 'ND']

    # Los nombres comunes de catalogos en hash con la lengua
    ncc = nombres_comunes.map {|nc| {nc.lengua => nc.nombre_comun.capitalize}}

    # Para los nombres comunes de naturalista
    if p = proveedor
      ncnat = p.nombres_comunes_naturalista
    else
      ncnat = {estatus: false}
    end

    if ncnat[:estatus]
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

  # REVISADO: Despleiga las categorias taxonomicas asociadas a un grupo iconico en la busqueda avanzada
  def cat_tax_asociadas
    nivel2 = root.nombre_cientifico.strip == 'Animalia' ? 1 : 0
    cats = CategoriaTaxonomica.cat_tax_asociadas(nivel2)

    if I18n.locale.to_s != 'es-cientifico'
      cats.where(nivel3: 0, nivel4: 0)
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

  # REVISADO Asigna todas las categorias y nombre cientificos a los ancestros de un taxon, para poder acceder a el mas facil
  def asigna_categorias

    path.select("#{Especie.attribute_alias(:nombre)} AS nombret, #{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} AS nombre_categoria_taxonomica").left_joins(:categoria_taxonomica).each do |ancestro|
      categoria = 'x_' << I18n.transliterate(ancestro.nombre_categoria_taxonomica).gsub(' ','_').downcase
      next unless Lista::COLUMNAS_CATEGORIAS.include?(categoria)
      eval("self.#{categoria} = ancestro.nombret")  # Asigna el nombre del ancestro si es que coincidio con la categoria

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