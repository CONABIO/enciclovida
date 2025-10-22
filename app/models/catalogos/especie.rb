class Especie < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.cat}.Nombre"
  self.primary_key = 'IdNombre'

  include AncestryPersonalizado
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
  alias_attribute :nombre_cientifico, :TaxonCompleto
  alias_attribute :created_at, :FechaCaptura
  alias_attribute :updated_at, :FechaModificacion

  # Atributos adicionales para poder exportar los datos a excel directo como columnas del modelo
  attr_accessor :x_estatus, :x_naturalista_id, :x_snib_id, :x_snib_reino, :x_categoria_taxonomica, :x_url_ev, 
                :x_naturalista_obs, :x_snib_registros, :x_geoportal_mapa, :x_num_reg, :x_idcat,
                :x_nom, :x_nom_obs, :x_iucn, :x_iucn_obs, :x_cites, :x_cites_obs, :x_tipo_distribucion, :x_distribucion, :x_ambiente, :x_usos,
                :x_nombres_comunes, :x_nombre_comun_principal, :x_lengua, :x_nombres_comunes_naturalista, :x_nombres_comunes_catalogos, :x_nombres_comunes_todos,
                :x_fotos, :x_foto_principal, :x_square_url, :x_fotos_principales, :x_fotos_totales, :x_naturalista_fotos, :x_bdi_fotos,
                :x_reino, :x_division, :x_subdivision, :x_clase, :x_subclase, :x_superorden, :x_orden, :x_suborden,
                :x_familia, :x_subfamilia, :x_epifamilia, :x_tribu, :x_subtribu, :x_genero, :x_subgenero, :x_seccion, :x_subseccion,
                :x_serie, :x_subserie, :x_especie, :x_subespecie, :x_variedad, :x_subvariedad, :x_forma, :x_subforma,
                :x_subreino, :x_superphylum, :x_phylum, :x_subphylum, :x_superclase, :x_subterclase, :x_grado, :x_infraclase,
                :x_infraorden, :x_superfamilia, :x_supertribu, :x_parvorden, :x_superseccion, :x_grupo,
                :x_infraphylum, :x_epiclase, :x_supercohorte, :x_cohorte, :x_subcohorte, :x_hibrido, :x_grupo_especies, :x_raza, :x_estirpe,
                :x_subgrupo, :x_hiporden, :x_infraserie, :x_infrareino, :x_superdivision,
                :x_bibliografia, :x_nombre_autoridad, :x_nombre_autoridad_infraespecie, :x_suprafamilia  # Para que en el excel sea mas facil la consulta
  :x_distancia
  alias_attribute :x_nombre_cientifico, :nombre_cientifico
  attr_accessor :e_geodata, :e_nombre_comun_principal, :e_foto_principal, :e_nombres_comunes, :e_categoria_taxonomica,
                :e_tipo_distribucion, :e_caracteristicas, :e_bibliografia, :e_fotos  # Atributos para la respuesta en json
  attr_accessor :jres  # Para las respuest en json
  # Para la parte de validar registros de la especie
  attr_accessor :coleccion, :formato

  has_one :proveedor
  has_one :adicional
  has_one :pez, :class_name => 'Pmc::Pez'
  has_one :scat, :foreign_key => attribute_alias(:id)

  belongs_to :categoria_taxonomica, :foreign_key => attribute_alias(:categoria_taxonomica_id)

  has_many :nombres_regiones, :class_name => 'NombreRegion', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  has_many :nombres_comunes, :through => :nombres_regiones, :source => :nombre_comun

  has_many :especies_regiones, :class_name => 'EspecieRegion', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  has_many :tipos_distribuciones, :through => :especies_regiones, :source => :tipo_distribucion
  has_many :regiones, :through => :especies_regiones, :source => :region

  has_many :nombres_regiones_bibliografias, :class_name => 'NombreRegionBibliografia', :dependent => :destroy

  has_many :especies_catalogos, :class_name => 'EspecieCatalogo', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  has_many :catalogos, :through => :especies_catalogos, :source => :catalogo

  has_many :especies_estatus, :class_name => 'EspecieEstatus', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  # Esta relacion se puso extra ya que los sinonimos no redireccionaban al valido
  has_many :especies_estatus_idnombrerel, :class_name => 'EspecieEstatus', :dependent => :destroy, :foreign_key => :IdNombreRel
  has_many :estatuses, :through => :especies_estatus, :source => :estatus

  has_many :especie_bibliografias, :class_name => 'EspecieBibliografia', :dependent => :destroy, :foreign_key => attribute_alias(:id)
  has_many :bibliografias, :through => :especie_bibliografias, :source => :bibliografia

  has_many :especie_estadisticas, :class_name => 'EspecieEstadistica', :dependent => :destroy, inverse_of: :especie
  has_many :estadisticas, :through => :especie_estadisticas, :source => :estadistica

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
  scope :datos_basicos, ->(attr_adicionales=[]) { select_basico(attr_adicionales).joins(:categoria_taxonomica, :adicional) }
  #Select para el Checklist
  scope :select_checklist, -> { select(:id, :nombre_cientifico).select("CONCAT(#{attribute_alias(:ancestry_ascendente_obligatorio)}, #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel2)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}) AS ancestry") }
  scope :select_ancestry, -> { select(:id).select("#{attribute_alias(:ancestry_ascendente_directo)} AS ancestry") }
  scope :datos_checklist, -> { select_checklist.order("ancestry") }
  scope :categorias_checklist, -> { where("#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} IN (?)", CategoriaTaxonomica::CATEGORIAS_CHECKLIST) }
  scope :datos_arbol_sin_filtros, -> {select("especies.id, nombre_cientifico, ancestry_ascendente_directo,
ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol, categoria_taxonomica_id,
categorias_taxonomicas.nombre_categoria_taxonomica, nombre_autoridad, estatus, nombre_comun_principal,
nombres_comunes as nombres_comunes_adicionales").categoria_taxonomica_join.adicional_join }

  #Selects para construir la taxonomía por cada uno del set de resultados cuando se usca por nombre cientifico en la básica
  scope :datos_arbol_para_json , -> {select("ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol")}
  scope :datos_arbol_para_json_2 , -> {select("especies.id, nombre_cientifico,
ancestry_ascendente_directo+'/'+cast(especies.id as nvarchar) as arbol, categorias_taxonomicas.nombre_categoria_taxonomica,
nombre_autoridad, estatus").categoria_taxonomica_join }
  #Select para la Subcoordinadora de Evaluación de Ecosistemas ()Ana Victoria Contreras Ruiz Esparza)
  scope :select_evaluacion_eco, -> { select('especies.id, nombre_cientifico, categoria_taxonomica_id, nombre_categoria_taxonomica, catalogo_id') }
  scope :order_por_categoria, ->(orden) { order("CONCAT(categorias_taxonomicas.nivel1,categorias_taxonomicas.nivel2,categorias_taxonomicas.nivel3,categorias_taxonomicas.nivel4) #{orden}") }

  # Select basico que contiene los campos a mostrar por ponNombreCientifico
  scope :select_basico, ->(attr_adicionales=[]) { select(:id, :nombre_cientifico, :estatus, :nombre_autoridad, :categoria_taxonomica_id, :cita_nomenclatural, :ancestry_ascendente_directo, :ancestry_ascendente_obligatorio, "nombre_comun_principal, foto_principal, nombres_comunes as nombres_comunes_adicionales, TaxonCompleto AS NombreCompleto" << (attr_adicionales.any? ? ",#{attr_adicionales.join(',')}" : '')).select_categoria_taxonomica }
  # Select para nombre de la categoria y niveles
  scope :select_categoria_taxonomica, -> { select("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} AS nombre_categoria_taxonomica, #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)} AS nivel1, #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel2)} AS nivel2, #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)} AS nivel3, #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)} AS nivel4") }
  #select para los grupos iconicos en la busqueda avanzada para no realizar varios queries al mismo tiempo
  scope :select_grupos_iconicos, -> { select(:id, :nombre_cientifico, :nombre_comun_principal).left_joins(:adicional).where(estadoRegistro: 1) }
  # Select para agurpar el los niveles de categoria taxonomica
  scope :select_nivel_categoria, -> { select("CONCAT(#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel2)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}) AS nivel_categoria") }
  # Scope para saber que taxones inferiores desplegar de acuerdo a la categoria en la busqueda vanzada
  #scope :nivel_categoria, ->(nivel, categoria) { where("CONCAT(#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel2)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}) #{nivel} '#{categoria}'") }
  scope :nivel_categoria, ->(nivel, categoria) { where("CONCAT(#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel2)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}) #{nivel} '7100' OR CONCAT(#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel2)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)},#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}) #{nivel} '7000'") }
  # Para que regrese las especies
  scope :solo_especies, -> { where("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)}=? AND #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)}=? AND #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel4)}=?", 7,0,0).left_joins(:categoria_taxonomica) }
  # Se ocupa en el home
  scope :conteo_especies_publicas_validas, -> { solo_especies.solo_publicos.where(estatus: 2).count }
  # Regresa solo las categorias obligatorias en categoria taxonomica
  scope :solo_cat_obligatorias, -> { where("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)}>0 AND #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)}=0 AND #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} IN (?)", CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS) }
  # Para mostrar solo los taxones publicos
  scope :solo_publicos, -> { left_joins(:scat).where("#{Scat.attribute_alias(:publico)}=?", 1) }
  # Para que regrese las especies e inferiores
  scope :especies_e_inferiores, -> { where("#{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel1)}=? AND #{CategoriaTaxonomica.table_name}.#{CategoriaTaxonomica.attribute_alias(:nivel3)}>?", 7,0).left_joins(:categoria_taxonomica) }
  # Query que saca los ancestros, nombres cientificos y sus categorias taxonomicas correspondientes
  scope :asigna_info_ancestros, -> { path.select("#{Especie.attribute_alias(:nombre)}, #{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)}").left_joins(:categoria_taxonomica) }  
  
  # Scope para cargar el arbol identado en la ficha de la espcie
  scope :arbol_select, -> { Especie.select_basico(['conteo']).select_nivel_categoria.left_joins(:adicional, :categoria_taxonomica, :especie_estadisticas) }
  # Scope para cargar el arbol identado inical en la ficha de la especie
  scope :arbol_inicial, ->(taxon, estadistica_id) { arbol_select.solo_publicos.where(id: taxon.path_ids).order('nivel_categoria ASC').where("estadistica_id=?",estadistica_id) }
  # Scope para cargar el arbol identado inical en la ficha de la especie, solo las categorias obligatorias
  scope :arbol_inicial_obligatorias, ->(taxon, estadistica_id) { arbol_inicial(taxon, estadistica_id).solo_cat_obligatorias.where(estatus: 2) }
  # Scope para los reinos iniciales en la busqueda por clasificacion
  # scope :arbol_reinos, ->(estadistica_id) { arbol_select.solo_publicos.where("estadistica_id=?",estadistica_id).where(id: [1..5]).order('nivel_categoria ASC') }
  scope :arbol_reinos, ->(estadistica_id) { arbol_select.solo_publicos.where("estadistica_id=?",estadistica_id).where("catalogocentralizado.Nombre.IdCategoriaTaxonomica = 1").order('nivel_categoria ASC') }
  # Scope para cargar las hojas del arbol
  scope :arbol_hojas, ->(taxon, estadistica_id, ascendente) { arbol_select.solo_publicos.where("#{attribute_alias(ascendente)}=#{taxon.id}").where.not(id: taxon.id).where("estadistica_id=?",estadistica_id).order(nombre_cientifico: :asc) }
  scope :arbol_hojas_obligatorias, ->(taxon, estadistica_id, ascendente) { arbol_hojas(taxon, estadistica_id, ascendente).solo_cat_obligatorias.where(estatus: 2) }

  # Scopes de estadisticas
  scope :conteo_estadisticas, ->(estadisticas, conteo) { left_joins(:estadisticas).where("estadistica_id IN (#{estadisticas})").where("conteo #{conteo} 0") }

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

  
  
  def self.update_geoserver_info(proveedores_hash)
    ts_req = Tropicos_Service.new

    proveedores_hash.each do |id_cat, data|
      scientific_name = data.dig("mapas", "Mapa 1", "nombre_cientifico")
      if scientific_name.nil?
        puts "No se encontró el nombre científico para IdCat #{id_cat}"
        next
      end
      begin 
        response = TaxonNaturalistaClient.fetch_taxa(scientific_name)
        if response.success? 
          taxa = response.parsed_response['resultados']
          if taxa.any?
            id_naturalista = taxa.first['id']
            puts id_naturalista
            # Encuentra el registro en la tabla SCAT donde el IdCat coincida
            scat_record = Scat.find_by(IDCAT: id_cat)
            if scat_record
              resultado = ts_req.get_id_name(scientific_name)
              if resultado[0].is_a?(Hash) && resultado[0][:msg].present?
                puts resultado[0][:msg]
              else
                name_id = resultado[0]["NameId"]
                puts "El NameId es: #{name_id}"
              end
              # Busca o inicializa un registro en proveedores con el especie_id correspondiente
              proveedor = Proveedor.find_or_initialize_by(especie_id: scat_record.IdNombre)
              # Convierte la colección de mapas a una cadena JSON
              mapas_json = data["mapas"].to_json
              # Actualiza el campo geoserver_info  y naturalista_id
              proveedor.geoserver_info = mapas_json
              proveedor.naturalista_id = id_naturalista
              proveedor.IdCAT = id_cat
              proveedor.tropico_id = name_id
              # Guarda el registro en la base de datos
              if proveedor.save
                puts "Registro para IdCat #{id_cat} actualizado/creado exitosamente."
              else
                puts "Error al guardar el registro para IdCat #{id_cat}: #{proveedor.errors.full_messages.join(", ")}"
              end
            else
              puts "No se encontró un registro en SCAT con IdCat: #{id_cat}"   
            end
          else
            puts "No se encontró ningún taxón con el nombre científico: #{scientific_name}"
            nil
          end
        else
          puts "Error en la solicitud: #{response.code} - #{response.message}"
          nil
        end
      rescue HTTParty::Error => e
        puts "Error en HTTParty: #{e.message}"
      rescue StandardError => e
        puts "Error general: #{e.message}"
      end
    end
  end

  # Sobre escribiendo este metodo para las rutas mas legibles
  def to_param
    [id, nombre_cientifico.parameterize].join("-")
  end

  # Regresa el taxon valido o el mismo en caso de serlo
  def dame_taxon_valido
    return self if estatus == 2  # el valido era el mismo
    est = especies_estatus_idnombrerel.where(estatus_id: [1,2])
    return nil unless est.first

    begin
      t = Especie.find(est.first.especie_id1)
      t.estatus == 2 ? t : nil
    rescue
      nil
    end
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

  # REVISADO: Para sacar los nombres de las categorias de IUCN, NOM, CITES, ambiente y prioritaria, regresa un array con los valores
  def nom_cites_iucn_ambiente_prioritaria(opc={})
    # Se ponen en grupos para poder meterles espacios cuando se despliegan en el show
    response = { grupo1: [], grupo2: [], grupo3: [], grupo4: [] }

    response[:grupo2] << {'NOM-059-SEMARNAT 2010' => catalogos.nom.map(&:descripcion).uniq}

    response[:grupo2] << {'Evaluación CONABIO' => catalogos.evaluacion_conabio.map do |cat|
      cat.descripcion + ' Evaluación CONABIO'
    end }

    if opc[:iucn_ws]
      iucn_ws = IUCNService.new.dameRiesgo(:nombre => nombre_cientifico, id: id)

      if iucn_ws.present?
        response[:grupo2] << {'IUCN Red List of Threatened Species 2017-1' => [iucn_ws]}
      else
        response[:grupo2] << {'IUCN Red List of Threatened Species 2017-1' => catalogos.iucn.map(&:descripcion).uniq}
      end

    else
      response[:grupo2] << {'IUCN Red List of Threatened Species 2017-1' => catalogos.iucn.map(&:descripcion).uniq}
    end

    response[:grupo3] << {'CITES 2016' => catalogos.cites.map(&:descripcion)}
    response[:grupo4] << {'Prioritarias DOF 2014' => catalogos.prioritarias.map(&:descripcion)}
    response[:grupo4] << {'Tipo de ambiente' => catalogos.ambientes.map(&:descripcion)}

    response
  end

  # REVISADO: Regresa en un hash todos los valores con las bibliorafias, para pestaña de catalogos especialmente
  def caracteristicas
    begin
      resp = {}

      caract = Especie.where(id: id).includes(especies_catalogos: [:catalogo, biblios: :bibliografia])

      caract.first.especies_catalogos.each do |esp_cat|
        cat = esp_cat.catalogo
        next unless cat.es_catalogo_permitido?
        nombre_catalogo = cat.dame_nombre_catalogo
        #biblio_cita_completa = esp_cat.biblios.map { |b| b.bibliografia.cita_completa }
        biblio_cita_completa = esp_cat.biblios_con_dos_foreign_keys.map { |b| b.bibliografia.cita_completa }
        seccion = nombre_catalogo.estandariza.to_sym

        resp[seccion] = { nombre_catalogo: nombre_catalogo, datos: [] } unless resp[seccion].present?
        resp[seccion][:datos] << { nombre_catalogo: nombre_catalogo, descripciones: [cat.descripcion], bibliografias: biblio_cita_completa, observaciones: esp_cat.observaciones }
      end
      resp
    rescue
      resp
    end    
  end

  # REVISADO: Devuelve el tipo de distribución para colocar en la simbologia del show de especies
  def tipo_distribucion(opc={})
    response = []

    tipos_distribuciones.uniq.each do |distribucion|
      response << distribucion.descripcion
    end

    # Si tiene endemica y nativa, solo dejamos endemica
    endemica_nativa = ["Endémica", "Nativa"] & response
    if endemica_nativa.length == 2
      response.delete_at(response.index("Nativa"))
    end

    {'Tipo de distribución' => response}
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

  # REVISADO: Regresa true si es un taxon apto para generar geodatos
  def apta_con_geodatos?
    CategoriaTaxonomica::CATEGORIAS_GEODATOS.include? categoria_taxonomica.nombre_categoria_taxonomica
  end

  # REVISADO: Servicio que trae la respuesta de bdi
  def fotos_bdi(opts={})
    bdi = BDIService.new({nombre_cientifico: nombre_cientifico}.merge(opts))
    bdi.dame_fotos
    bdi
  end

  # Servicio que trae la respuesta de bdi para videos
  def videos_bdi(opts={})
    bdi = BDIService.new
    bdi.dame_videos(opts.merge({taxon: self}))
  end

  # REVISADO: Devuelve todas las fotos de diferentes proveedores  en diferentes formatos
  def dame_fotos_todas
    # Fotos de naturalista
    if p = proveedor
      p.fotos_naturalista
      self.jres = p.jres

      if jres[:estatus]
        self.x_fotos_totales = jres[:fotos].count

        if jres[:fotos].count > 0
          self.x_square_url = jres[:fotos].first['photo']['square_url']
          self.x_foto_principal = jres[:fotos].first['photo']['medium_url'] || jres[:fotos].first['photo']['large_url']
        end
      end
    end

    # Fotos de bdi
    bdi = fotos_bdi
    self.x_fotos_totales+= bdi.num_assets
  end

  # REVISADO: regresa todos los nombres comunes de catalogos
  def dame_nombres_comunes_catalogos
    # Los nombres comunes de catalogos en hash con la lengua
    ncc = nombres_comunes.map {|nc| {nc.lengua => nc.nombre_comun.capitalize}}
    #ncc_estandar = ncc.map{|n| n.values.map(&:estandariza)}.flatten

    nombres_inicio = []
    nombres_mitad = []
    nombres_final = []

    ncc.each do |nombre|
      lengua = nombre.keys.first  # Ya que es un hash

      if NombreComun::LENGUAS_PRIMERO.include?(lengua)
        index = NombreComun::LENGUAS_PRIMERO.index(lengua)

        # Crea el arreglo dentro del hash lengua para agrupar nombres de la misma lengua
        if nombres_inicio[index].nil?
          nombres_inicio[index] = {}
          nombres_inicio[index][lengua] = []
        end

        nombres_inicio[index][lengua] << nombre[lengua]

      elsif NombreComun::LENGUAS_ULTIMO.include?(lengua)
        index = NombreComun::LENGUAS_ULTIMO.index(lengua)

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

    # Los uno para obtener sus respectivas posiciones
    (nombres_inicio + nombres_mitad + nombres_final).compact
  end

  # REVISADO: regresa todos los nombres comunes en diferentes proveedores en diferentes formatos
  def dame_nombres_comunes_todos
    self.jres = { estatus: false, msg: 'Hubo un error al procesar los nombres comunes' }  # mensaje default

    # Los nombres comunes de catalogos en hash con la lengua
    ncc = nombres_comunes.map {|nc| {nc.lengua => nc.nombre_comun.capitalize}}
    ncc_estandar = ncc.map{|n| n.values.map(&:estandariza)}.flatten

    # Para los nombres comunes de naturalista
    if p = proveedor
      p.nombres_comunes_naturalista
      self.jres = p.jres
    end

    

    if jres[:estatus]
      ncn = jres[:nombres_comunes].map do |nc|
        next if nc['name'].blank? || nc['locale'].blank? || nc['locale'] == 'sci' || NombreComun::LENGUAS_PROHIBIDAS.include?(I18n.t("lenguas.#{nc['locale'].estandariza}", default: "ND"))

        # Un nombre de catalogos es igual que uno de Naturalista, conservo el de Naturalista
        if ncc_estandar.present? && ncc_estandar.include?(nc['name'].estandariza)
          ncc.each_with_index do |h, index|
            ncc.delete_at(index) if h.values.join('').estandariza == nc['name'].estandariza
          end
        end

        # Asigna la lengua
        lengua = nc['locale']
        l = if lengua.present?
              lengua.estandariza
            else
              'nd'
            end

        # Los nombres comunes de naturalista en hash con la lengua
        { I18n.t("lenguas.#{l}", default: l.capitalize) => nc['name'].capitalize }
      end
    else
      ncn = []
    end
    # Para el orden de las lenguas
    nombres = (ncn + ncc).uniq.compact
    nombres_inicio = []
    nombres_mitad = []
    nombres_final = []

    nombres.each do |nombre|
      lengua = nombre.keys.first  # Ya que es un hash

      if NombreComun::LENGUAS_PRIMERO.include?(lengua)
        index = NombreComun::LENGUAS_PRIMERO.index(lengua)

        # Crea el arreglo dentro del hash lengua para agrupar nombres de la misma lengua
        if nombres_inicio[index].nil?
          nombres_inicio[index] = {}
          nombres_inicio[index][lengua] = []
        end

        nombres_inicio[index][lengua] << nombre[lengua]

      elsif NombreComun::LENGUAS_ULTIMO.include?(lengua)
        index = NombreComun::LENGUAS_ULTIMO.index(lengua)

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
    todos = (nombres_inicio + nombres_mitad + nombres_final).compact

    if todos.any?
      todos_array = todos.map(&:values).flatten
      self.x_nombres_comunes = todos_array.join(',')
      self.x_nombre_comun_principal = todos_array.first
      self.x_lengua = todos.first.keys.first
      self.x_nombres_comunes_todos = todos
    end
  end

  # REVISADO: Despliega las categorias taxonomicas asociadas a un grupo iconico en la busqueda avanzada
  def cat_tax_asociadas
    nivel2 = root.nombre_cientifico.strip == 'Animalia' ? 1 : 0
    cats = CategoriaTaxonomica.cat_tax_asociadas(nivel2)

    if I18n.locale.to_s != 'es-cientifico'
      cats.where(nivel3: 0, nivel4: 0)
    end

    cats
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

  # REVISADO: Pone el nombre comun que haya coincidido, de acuerdo a la lista,
  def cual_nombre_comun_coincidio(nombre, fuzzy_match=false)
    # nombres_comunes_adicionales es un alias a nombres_comunes de adicionales
    return self.x_nombre_comun_principal = nil unless nombres_comunes_adicionales.present?
    nombres = nombres_comunes_adicionales.split(',')
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

  # Condiciones que deben de cumplir
  def valida_registros
    # Para no generar descargas arriba de especie
    return self.jres = { estatus: false, msg: 'No es una especie o subespecie' } unless apta_con_geodatos?
    # Que haya registro en Scat
    return self.jres = { estatus: false, msg: 'No existe registro en Scat' } unless s = scat
    catalogo_id = s.catalogo_id
    return self.jres = { estatus: false, msg: 'El IdCAT esta vacio' } unless catalogo_id.present?
    self.jres = { estatus: true, catalogo_id: catalogo_id }
  end

  # Validacion para saber si la especie es valida para registros
  def descarga_registros
    valida_registros
    return jres unless jres[:estatus]

    geo = Geoportal::Snib.new({ params: { catalogo_id: jres[:catalogo_id], coleccion: coleccion, formato: formato, taxon: self } })
    geo.guarda_registros
    self.jres = geo.resp
  end
  
  # REVISADO: Borra todos los json, kml, kmz del taxon en cuestion
  def borra_geodata
    ruta = Rails.root.join('public', 'geodatos', id.to_s, "*")
    archivos = Dir.glob(ruta)

    archivos.each do |a|
      File.delete(a)
    end
  end

  # REVISADO: Devuelve una lista de todas las URLS asociadas a los geodatos
  def consulta_geodatos
    geodatos = {}
    geodatos[:cuales] = []

    # Geoserver
    if p = proveedor
      p.dame_geoserver
      
      if p.jres[:estatus]
        geodatos[:cuales] << "geoserver"
        geodatos[:geoserver_url] = CONFIG.geoserver_url
        geodatos[:geoserver_urls] = p.jres[:geoserver_urls]
      end
    end

    # Validacion para registros del snib y naturalista
    valida_registros
    return geodatos unless jres[:estatus]
    
    # URL para la consulta de registros
    url = "#{CONFIG.site_url}especies/#{id}/consulta-registros"

    geo = Geoportal::Snib.new({ params: { catalogo_id: jres[:catalogo_id], coleccion: 'snib' } })
    geo.tiene_registros?
    
    if geo.resp[:estatus]
      geodatos[:cuales] << "snib"
      geodatos[:snib_json] = "#{url}.json?coleccion=snib&formato=json"
      geodatos[:snib_kml] = "#{url}.kml?coleccion=snib&formato=kml"
      geodatos[:snib_kmz] = "#{url}.kmz?coleccion=snib&formato=kmz"
      geodatos[:snib_mapa_json] = "#{url}.json?coleccion=snib&formato=mapa-app"
    end
    
    geo = Geoportal::Snib.new({ params: { catalogo_id: jres[:catalogo_id], coleccion: 'naturalista' } })
    geo.tiene_registros?
    
    if geo.resp[:estatus]
      geodatos[:cuales] << "naturalista"
      geodatos[:naturalista_json] = "#{url}.json?coleccion=naturalista&formato=json"
      geodatos[:naturalista_kml] = "#{url}.kml?coleccion=naturalista&formato=kml"
      geodatos[:naturalista_kmz] = "#{url}.kmz?coleccion=naturalista&formato=kmz"
      geodatos[:naturalista_mapa_json] = "#{url}.json?coleccion=naturalista&formato=mapa-app"
    else  # TODO: este else no tiene sentido de ir, es una aberracion hasta que sepamos modificar las apps
      geodatos[:naturalista_mapa_json] = "#{url}.json?coleccion=naturalista&formato=mapa-app"
    end

    geodatos
  end

end
