class Busqueda
  attr_accessor :params, :taxones, :totales, :por_categoria, :es_cientifico, :original_url, :formato,
                :pagina, :por_pagina, :offset, :taxon, :estadisticas

  POR_PAGINA = [50, 100, 200]
  POR_PAGINA_PREDETERMINADO = POR_PAGINA.first

  NIVEL_CATEGORIAS = [
      ['inferior o igual a', '>='],
      ['inferior a', '>'],
      ['igual a', '='],
      ['superior o igual a', '<='],
      ['superior a', '<']
  ]

  GRUPOS_REINOS = %w(Animalia Plantae Fungi Prokaryotae Protoctista)
  GRUPOS_ANIMALES = %w(Mammalia Aves Reptilia Amphibia Actinopterygii Petromyzontidae Myxini Chondrichthyes
Arachnida Insecta Mollusca Crustacea Annelida Myriapoda Echinodermata Cnidaria Porifera)
  GRUPOS_PLANTAS = %w(Bryophyta Anthocerotophyta Polypodiidae Pinidae Cycadidae Lilianae Magnoliidae)
  
  BUSCADORES = {
		  clasificacion: {url: "/explora-por-clasificacion", nombre: "Clasificación", descripcion: "¡Explora toda la clasificación taxonómica desde reinos hasta especies!"},
		  region: {url: "/explora-por-region", nombre: "Región", descripcion: "¡Realiza búsquedas por estados, municipios o áreas naturales protegidas!"},
		  usos: {url: "/busquedas/resultados?utf8=%E2%9C%93&nombre=&busqueda=avanzada&id=&uso%5B%5D=11-4-0-0-0-0-0&uso%5B%5D=11-16-0-0-0-0-0&uso%5B%5D=11-5-0-0-0-0-0&uso%5B%5D=11-40-1-0-0-0-0&uso%5B%5D=11-40-2-0-0-0-0&uso%5B%5D=11-8-0-0-0-0-0&uso%5B%5D=11-9-0-0-0-0-0&uso%5B%5D=11-10-0-0-0-0-0&uso%5B%5D=11-11-0-0-0-0-0&uso%5B%5D=11-13-0-0-0-0-0&uso%5B%5D=11-15-0-0-0-0-0&uso%5B%5D=11-14-0-0-0-0-0&por_pagina=50&commit=", nombre: "Usos", descripcion: "¡Descubre las especies agrupadas por el uso que tienen!"},
		  "en-riesgo" => {url: "/busquedas/resultados?utf8=%E2%9C%93&nombre=&busqueda=avanzada&id=&edo_cons%5B%5D=16&edo_cons%5B%5D=14&edo_cons%5B%5D=15&edo_cons%5B%5D=17&edo_cons%5B%5D=25&edo_cons%5B%5D=26&edo_cons%5B%5D=27&edo_cons%5B%5D=28&edo_cons%5B%5D=29&edo_cons%5B%5D=1102&edo_cons%5B%5D=1103&edo_cons%5B%5D=1104&edo_cons%5B%5D=22&edo_cons%5B%5D=23&edo_cons%5B%5D=24&por_pagina=50&commit=", nombre: "En riesgo", descripcion: "¡Navega por las especies que tienen asociada alguna categoría de riesgo tanto nacional como internacional!"},
		  distribucion: {url: "/busquedas/resultados?utf8=%E2%9C%93&nombre=&busqueda=avanzada&id=&dist%5B%5D=3&dist%5B%5D=7&dist%5B%5D=10&dist%5B%5D=6&por_pagina=50&commit=", nombre: "Distribución", descripcion: "¡Ubica las especies por su tipo de distribución (endémica, nativa, exótica o exótica invasora)!"},
		  "exotica-invasora" => {url: "/exoticas-invasoras", nombre: "Exóticas invasoras", descripcion: "¡Conoce las especies exóticas invasoras en el país!"},
		  "peces-mariscos-comerciales" => {url: "/peces", nombre: "Consumo marino responsable", descripcion: "¡Informate con el semáforo de consumo responsable acerca de pesquerías sustentables y sus criterios de pesca!"},
		  avanzada: {url: "/avanzada", nombre: "Avanzada", descripcion: "¡Combina los criterios de búsqueda anteriores junto a otros tales como: tipo de ambiente, la distribución reportada en literatura y por grupo icónico!"} }
  
  # REVISADO: Inicializa los objetos busqueda
  def initialize
    self.taxones = Especie.left_joins(:categoria_taxonomica, :adicional, :scat).distinct
    self.totales = 0
  end

  # REVISADO: Filtros de tipos de distribucion
  def tipo_distribucion
    if params[:dist].present? && params[:dist].any?
      self.taxones = taxones.where("#{TipoDistribucion.table_name}.#{TipoDistribucion.attribute_alias(:id)} IN (?)", params[:dist]).left_joins(:tipos_distribuciones)
    end
  end

  # Para el select de usos
  def uso
    if params[:uso].present? && params[:uso].any?
      self.taxones = taxones.left_joins(:catalogos)
      niveles = []

      params[:uso].each_with_index do |uso, i|
        uso.split('-').each_with_index do |val,index|

          if val.to_i == 0  # Arma el query con este uso
            niveles[i] = niveles[i].join(' AND ')
            break
          end

          niveles[i] = [] unless niveles[i].present?
          niveles[i] << "#{Catalogo.table_name}.#{Catalogo.attribute_alias("nivel#{index+1}")}=#{val}"
        end
      end

      self.taxones = taxones.where(niveles.join(' OR '))
    end
  end

  # Para el select de ambiente
  def ambiente
    if params[:ambiente].present? && params[:ambiente].any?
      self.taxones = taxones.where("#{Catalogo.table_name}.#{Catalogo.attribute_alias(:id)} IN (?)", params[:ambiente]).left_joins(:catalogos)
    end
  end

  # Para el select de las regiones (estados y ecorregiones marinas)
  def region
    if params[:reg].present? && params[:reg].any?
      self.taxones = taxones.where("#{EspecieRegion.table_name}.#{EspecieRegion.attribute_alias(:region_id)} IN (?)", params[:reg]).left_joins(:especies_regiones)
    end
  end

  def busca_estadisticas
    return unless params[:controller]=='estadisticas'

    case params["tipoResultado"]
    when 'mayorCero'
      conteo = '>'
    when 'cero'
      conteo = '='
    when 'mayorIgualCero'
      conteo = '>='
    else
      conteo = '>'
    end

    # Si se definieron las estadísticas
    estadisticas_a_mostrar = if params["showEstadisticas"].present?
                               params["showEstadisticas"]
                             else
                               Estadistica::ESTADISTICAS_A_MOSTRAR
                             end

    # Extraer los taxones en hash
    self.taxones = taxones.conteo_estadisticas(estadisticas_a_mostrar.join(','), conteo)
    resultados = taxones.select('estadistica_id, descripcion_estadistica, COUNT(estadistica_id) AS conteo').group(:estadistica_id, :descripcion_estadistica)

    self.estadisticas = resultados.map{ |e| { e.estadistica_id => { nombre_estadistica: e.descripcion_estadistica, conteo: e.conteo }}}
    self.totales = taxones.count
  end

  # REVISADO: filtros de categorias de riesgo, nivel de prioridad
  def estado_conservacion
    if params[:edo_cons].present? || params[:prior].present?
      catalogos = (params[:edo_cons] || []) + (params[:prior] || [])
      self.taxones = taxones.where("#{Catalogo.table_name}.#{Catalogo.attribute_alias(:id)} IN (?)", catalogos).left_joins(:catalogos)
    end
  end

  # REVISADO: Por si selecciono un grupo iconico, eligio del autocomplete un taxon o escribio un nombre
  def por_id_o_nombre
    if params[:id].present? || params[:id_gi].present?  # Tiene mas importancia si escogio por id
      begin
        self.taxon = Especie.find(params[:id].present? ? params[:id] : params[:id_gi])
        true
      rescue
        self.taxones = Especie.none
        false
      end
    elsif params[:nombre].present?
      self.taxones = taxones.caso_nombre_comun_y_cientifico(params[:nombre].strip).left_joins(:nombres_comunes)
      true
    else  # Si no esta presente que siga con el flujo del programa
      true
    end
  end

  # REVISADO: Los resultados por categoria taxonomica de acuerdo a las pestañas
  def conteo_por_categoria_taxonomica
    return if !(pagina == 1 && params[:solo_categoria].blank? && formato != 'xlsx')

    por_categoria = taxones.
        select(:categoria_taxonomica_id, "#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} AS nombre_categoria_taxonomica, COUNT(DISTINCT #{Especie.table_name}.#{Especie.attribute_alias(:id)}) AS cuantos, #{CategoriaTaxonomica.attribute_alias(:nivel2)} AS nivel2").
        group(:categoria_taxonomica_id, CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)).
        order(CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica))

    self.por_categoria = por_categoria.map{|cat| {nombre_categoria_taxonomica: cat.nombre_categoria_taxonomica,
                                                  cuantos: cat.cuantos, url: "#{original_url}&solo_categoria=#{cat.categoria_taxonomica_id}",
                                                  categoria_taxonomica_id: cat.categoria_taxonomica_id, nivel2: cat.nivel2}}
  end

  # REVISADO: Solo la categoria que escogi, en caso de haber escogido una pestaña en especifico
  def solo_categoria
    if params[:solo_categoria].present?
      self.taxones = taxones.where(CategoriaTaxonomica.attribute_alias(:id) => params[:solo_categoria])
    end
  end

  # REVISADO: Pone el estatus de acuerdo a la vista
  def estatus
    if es_cientifico
      self.taxones = taxones.where(estatus: params[:estatus]) if params[:estatus].present? && params[:estatus].length > 0
    else  # En la vista general solo el valido
      self.taxones = taxones.where(estatus: 2)
    end
  end

  # REVISADO: Condicion para regresar solo los taxones publicos
  def solo_publicos
    self.taxones = taxones.where("#{Scat.table_name}.#{Scat.attribute_alias(:publico)} = 1")
  end

  # REVISADO: ALgunos valores como el offset, pagina y por pagina
  def paginado_y_offset
    self.pagina = (params[:pagina] || 1).to_i
    self.por_pagina = params[:por_pagina].present? ? params[:por_pagina].to_i : POR_PAGINA_PREDETERMINADO
    self.offset = (pagina-1)*por_pagina
  end

  # REVISADO: Por si carga la pagina de un inicio, o es una descarga
  def dame_totales
    if (pagina == 1 && params[:solo_categoria].blank?) || formato == 'xlsx'
      self.totales = taxones.count
    end
  end


  protected

  # REVISADO: Regresa el ID de la centralizacion de acuerdo a uin nombre comun dado
  def id_referencia_a_nombre_comun(id_referencia)
    id_referencia.to_s[1..6].to_i
  end
end
