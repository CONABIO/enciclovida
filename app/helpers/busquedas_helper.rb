module BusquedasHelper

  # Opciones default para el bootstrap-select plugin
  @@opciones = { class: 'selectpicker form-control form-group', 'data-live-search-normalize': true, 'data-live-search': true, 'data-selected-text-format': 'count', 'data-select-all-text': 'Todos', 'data-deselect-all-text': 'Ninguno', 'data-actions-box': true, 'data-none-results-text': 'Sin resultados para {0}', 'data-count-selected-text': '{0} seleccionados', title: '- - Selecciona - -', multiple: true }

  # REVISADO: Filtros para los grupos icónicos en la búsqueda avanzada vista general
  def radioGruposIconicos(resultados = false)
    def arma_span(taxon)
      "<label>#{radio_button_tag('id_gi', taxon.id, false, id: "id_gi_#{taxon.id}")}<span class='mx-1'><span title='#{taxon.nombre_comun_principal}' class='#{taxon.nombre_cientifico.parameterize}-ev-icon btn-title'></span></span></label>"
    end

    radios = '<div class="col-md">'
    radios << '<h6><strong>Reinos</strong></h6>'
    @reinos.each do |taxon|  # Para tener los grupos ordenados
      radios << arma_span(taxon)
    end
    radios << '</div>'
    radios << '<div class="w-100"></div>' if resultados

    radios << '<div class="col-md">'
    radios << '<h6><strong>Grupos de animales</strong></h6>'
    @animales.each do |taxon|  # Para tener los grupos ordenados
      radios << arma_span(taxon)
    end
    radios << '</div>'
    radios << '<div class="w-100"></div>' if resultados

    radios << '<div class="col-md">'
    radios << '<h6><strong>Grupos de plantas</strong></h6>'
    @plantas.each do |taxon|  # Para tener los grupos ordenados
      radios << arma_span(taxon)
    end
    radios << '</div>'
    radios << '<div class="w-100"></div>' if resultados

    "<div class='row'>#{radios}</div>"
  end

  # REVISADO: Filtros para categorías de riesgo y comercio internacional
  def checkboxEstadoConservacion(opciones={})
    opc = @@opciones.merge(opciones)
    options = @nom_cites_iucn_todos.map{ |k,v| [t(k), v.map{ |val| [val.descripcion, val.id, { class: "#{val.descripcion.estandariza}-ev-icon f-fuentes" }] }] }
    select_tag('edo_cons', grouped_options_for_select(options), opc)
  end

  # REVISADO: Filtros para Tipos de distribuciónes
  def checkboxTipoDistribucion(opciones={})
    opc = @@opciones.merge(opciones)
    options = @distribuciones.map{ |d| [d.descripcion, d.id, { class: "#{d.descripcion.estandariza}-ev-icon f-fuentes" }] }
    select_tag('dist', options_for_select(options), opc)
  end

  # REVISADO: Filtros para Especies prioritarias para la conservación
  def checkboxPrioritaria(opciones={})
    opc = @@opciones.merge(opciones)
    options = @prioritarias.map{ |p| [p.descripcion, p.id, { class: "#{p.descripcion.estandariza}-ev-icon f-fuentes" }] }
    select_tag('prior', options_for_select(options), opc)
  end

  # REVISADO: Filtros para estatus taxonómico en la busqueda avanzada
  def checkboxSoloValidos
    "<label for='estatus'><span title='Solo válidos/aceptados'>Solo válidos/aceptados</span></label> #{check_box_tag('estatus[]', 2, false, id: "estatus_2", class:'form-control')}"
  end

  def selectUsos(opciones={})
    opc = @@opciones.merge(opciones)
    options = @usos.map{ |u| [u.descripcion, u.id, { class: "f-fuentes" }] }
    select_tag('uso', options_for_select(options), opc)
  end

  def selectAmbiente(opciones={})
    opc = @@opciones.merge(opciones)
    options = @ambientes.map{ |a| [a.descripcion, a.id, { class: "#{a.descripcion.estandariza}-ev-icon f-fuentes" }] }
    select_tag('ambiente', options_for_select(options), opc)
  end

  def selectRegiones(opciones={})
    opc = @@opciones.merge(opciones)
    options = @regiones.map{ |k,v| [t("regiones.#{k.estandariza}"), v.map{ |val| [k.estandariza == 'estado' ? t("estados.#{val.nombre_region.estandariza}", default: val.nombre_region) : t("ecorregiones-marinas.#{val.nombre_region.estandariza}", default: val.nombre_region), val.id, { class: "#{val.nombre_region.estandariza}-ev-icon f-fuentes" }] }] }
    select_tag('reg', grouped_options_for_select(options), opc)
  end

  # Si la búsqueda ya fue realizada y se desea generar un checklist, unicamente se añade un parametro extra y se realiza la búsqueda as usual
  def checklist(datos)
    if datos[:totales] > 0
      sin_page_per_page = datos[:request].split('&').map{|attr| attr if !attr.include?('pagina=')}
      peticion = sin_page_per_page.compact.join('&')
      peticion << "&por_pagina=#{datos[:totales]}&checklist=1"
    else
      ''
    end
  end

  # Para las descargas
  def campoCorreo(recurso)
    html = ''

    if usuario_signed_in?
      html << text_field_tag('correo-' + recurso, current_usuario.email, class: 'form-control hidden', placeholder: 'correo ...')
    else
      html << label_tag('correo-'+recurso, 'Correo electrónico ', class: 'control-label')
      html << text_field_tag('correo-'+recurso, nil, class: 'form-control', placeholder: 'correo ...')
    end

    html
  end

  # El boton de las descargas
  def botonDescarga(recurso)
    if usuario_signed_in?
      "<button type='button' class='btn btn-success' id='boton-descarga-#{recurso}'>Enviar</button>"
    else
      "<button type='button' class='btn btn-success' id='boton-descarga-#{recurso}' disabled='disabled'>Enviar</button>"
    end
  end

  # Despliega el checklist
  def generaChecklist(taxon)
    html = ''
    nombre_cientifico = "<text class='f-nom-cientifico-checklist'>#{taxon.nombre_cientifico}</text>"

    unless taxon.especie_o_inferior?
      cat = taxon.nombre_categoria_taxonomica
      html << "<text class='f-categoria-taxonomica-checklist'>#{cat}</text> #{nombre_cientifico}"
      html << " #{taxon.nombre_autoridad}"
    else
      html << nombre_cientifico
      html << " #{taxon.nombre_autoridad}"

      html << '<div>'
      html << nombresComunesChecklist(taxon)
      html << '</div>'
    end

    html
  end

  # Devuelve los nombres comunes agrupados por lengua, solo de catalogos
  def nombresComunesChecklist(taxon)
    nombres = taxon.dame_nombres_comunes_catalogos
    return '' unless nombres.any?
    html = '<br /><label>Nombre(s) común(es): </label>'

    nombres.each do |hash_nombres|
      lengua = hash_nombres.keys.first
      html << "<span>#{hash_nombres[lengua].sort.join(', ')} <sub><i>#{lengua}</i></sub>;</span>"
    end

    html
  end

  def categoriasRiesgoChecklist(taxon)

  end

end
