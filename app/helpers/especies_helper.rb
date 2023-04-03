module EspeciesHelper

  def generaDescripcionTecnica(taxon)
    fichaTecnica = []
    fichaTecnica << dameEstatus(taxon)
    fichaTecnica << dameDistribucion(taxon)
    fichaTecnica << dameSinonimosUhomonimosDescripcionTecnica(taxon, {tipo_recurso: 'Sinónimos'})
    fichaTecnica << dameCaracteristica(taxon)
    fichaTecnica << dameEspecieBibliografias(taxon)
    fichaTecnica << dameOtrosAtributos(taxon)
    fichaTecnica << dameNomComunesBiblio(taxon)
    #{distribucion_literatura: dameDistribucionLiteratura(taxon, opc = {})}
    fichaTecnica.flatten

  end

#########################################################################################################################################
# REVISADO: Pone el estatus taxonómico de la especie, si no existe en la variable ESTATUS_SIGNIFICADO ponerla
  def dameEstatus(taxon)
    {nombre_catalogo: "Estatus taxonómico", descripciones: [Especie::ESTATUS_SIGNIFICADO[taxon.estatus]]}
  end

#########################################################################################################################################
# REVISADO: Regresa la distribucion de catalogos en forma de array para acomodarlo mejor en la vista
  def dameDistribucion(taxon)
    # Hago el cambio de locale a es-cientifico y regreso al original, ya que la pestaña de ficha técnica siempre la toma de catálogos
    locale_original = I18n.locale.to_s
    I18n.locale = 'es-cientifico' if I18n.locale.to_s == 'es'
    distribuciones = taxon.tipo_distribucion.values.flatten.compact
    I18n.locale = locale_original if I18n.locale.to_s != locale_original
    {nombre_catalogo: "Tipo de distribución", descripciones: distribuciones}
  end

#########################################################################################################################################
# REVISADO: Una misma funcion para sinonimos u homonimos
  def dameSinonimosUhomonimosDescripcionTecnica(taxon, opciones={})
    ids = taxon.especies_estatus.send(opciones[:tipo_recurso].estandariza).map(&:especie_id2)
    return [] if !ids.any?
    taxones = Especie.find(ids)
    lista = []

    taxones.each do |taxon|
      nombre = "&middot;" + tituloNombreCientifico(taxon, render: 'inline')
      bibliografias = taxon.bibliografias.map(&:cita_completa)

      if bibliografias.any?
        biblio_html = "<ul>#{bibliografias.map{ |b| "<li>#{b.gsub("\"","'")}</li>" }.join('')}</ul>"
        nombre << "<a href='' tabindex='0' class='biblio-cat btn btn-link' data-toggle='popover' data-trigger='focus' data-placement='top' title='Bibliografía' data-content=\"#{biblio_html}\" onClick='return false;'><i class='fa fa-book'></i></a>"
      end
      lista << nombre
    end
    {nombre_catalogo: opciones[:tipo_recurso], descripciones: lista}
  end

#########################################################################################################################################
# REVISADO: Pone las respectivas categorias de riesgo, distribucion y ambiente en el show de especies; pestaña de catalogos
  def dameCaracteristica(taxon)
    lista =[]
    caracteristicas = taxon.caracteristicas

    caracteristicas.each do |catalogo, valores|

      html = ''

      valores[:datos].each do |dato|
        biblio = dato[:bibliografias].any? ? "<ul>#{dato[:bibliografias].map{ |b| "<li>#{b}</li>" }.join('')}</ul>" : ''
        biblio_html = " <a tabindex='0' class='btn btn-link biblio-cat' role='button' data-toggle='popover' data-trigger='focus'
title='Bibliografía' data-content='#{biblio}'><i class='fa fa-book'></i></a>" if biblio.present?
        observaciones = dato[:observaciones] if dato[:observaciones].present?
        dato[:descripciones].each do |l|
          html << "#{l} #{biblio_html}"
        end
        lista << {nombre_catalogo: valores[:nombre_catalogo], descripciones: [html], observaciones: observaciones}
      end


    end
    lista

  end

#########################################################################################################################################
# REVISADO: Regresa las bibliografias de la especie del nombre cientifico en el show de especies
  def dameEspecieBibliografias(taxon)
    lista = []
    taxon.bibliografias.each do |bib|
      lista << bib.cita_completa if bib.cita_completa.present?
    end
    {nombre_catalogo: "Bibliografía del nombre científico", descripciones: lista}
  end

#########################################################################################################################################
# REVISADO: Otros atributos simples del modelo especie
  def dameOtrosAtributos(taxon)
    otros_attr = {'Cita nomenclatural' => 'cita_nomenclatural', 'Fuente de la información' => 'sist_clas_cat_dicc',
                  'Anotación' => 'anotacion', 'Fecha de ultima modificación' => 'updated_at'}
    lista = []

    otros_attr.each do |nom, attr|
      # Este cambio es para quitar anotaciones que diga eliminar, peticion del CAT
      next if attr == "anotacion" && taxon.anotacion.estandariza == "eliminar"

      valor = taxon.send(attr)
      if valor.present?
        valor = valor.strftime('%Y-%m-%d') if attr == 'updated_at'
        lista << {nombre_catalogo: nom, descripciones: [valor] }
      end
    end

    lista
  end
#########################################################################################################################################
# REVISADO: Nombres comunes con su bibliografia como referencia
  def dameNomComunesBiblio(taxon)
    lista = []

    taxon.nombres_comunes.distinct.order(:nombre_comun).each do |nombre|
      n = "&middot; #{nombre.nombre_comun} <sub><i>#{nombre.lengua}</i></sub>"
      bibliografias = nombre.bibliografias.con_especie(taxon).map(&:cita_completa)
      if bibliografias.any?
        biblio_html = "<ul>#{bibliografias.map{ |b| "<li>#{b}</li>" }.join('')}</ul>"
        n << "<a href='' tabindex='0' class='biblio-cat btn btn-link' data-toggle='popover' data-trigger='focus' data-placement='top' title='Bibliografía' data-content=\"#{biblio_html}\" onClick='return false;'><i class='fa fa-book'></i></a>"
      end
      lista << n
    end

    {nombre_catalogo: 'Nombres comunes', descripciones: lista}
  end

#########################################################################################################################################
# REVISADO: La distribucion reportada en literatura, para el show de especies en la pestaña de catalogos
  def dameDistribucionLiteratura(taxon, opc={})
    def creaLista(regiones, opc={})
      lista = []

      regiones.each do |id, datos|
        lista << "<li>#{datos[:nombre]}</li>"

        if !opc[:app]
          lista << " <a href='' tabindex='0' class='biblio-cat' data-toggle='popover' data-trigger='focus' data-placement='top' title='Bibliografía' data-content=\"#{datos[:observaciones]}\" onClick='return false;'>Bibliografía</a>" if datos[:observaciones].present?
        end

        if datos[:reg_desc].any?
          sub_reg = creaLista(datos[:reg_desc], opc)
          lista << sub_reg
        end
      end

      "</strong><ul>#{lista.join('')}</ul>"
    end

    regiones = taxon.regiones.select_observaciones.validas.distinct
    reg_asignadas = Region.regiones_asignadas(regiones)
    "<p><strong>Distribución reportada en literatura</strong>#{creaLista(reg_asignadas, opc)}</p>".html_safe
  end

#########################################################################################################################################
  def creaPopOverBibliografia(biblio)
    biblio.each do |b|

    end
  end







# REVISADO: Una misma funcion para sinonimos u homonimos
  def dameSinonimosUhomonimos(taxon, opciones={})
    def creaContenedor(recurso, opciones={})
      "<strong>#{opciones[:tipo_recurso]}: </strong>#{recurso.join(' <b>;</b> ')}"
    end

    ids = taxon.especies_estatus.send(opciones[:tipo_recurso].estandariza).map(&:especie_id2)

    return '' unless ids.any?

    taxones = Especie.find(ids)
    recurso = taxones.map{ |t| tituloNombreCientifico(t, render: 'inline') }
    creaContenedor(recurso, opciones).html_safe

  end

# REVISADO: Pone las respectivas categorias de riesgo, distribucion y ambiente en el show de especies
  def ponCaracteristicaDistribucionAmbienteTaxon(taxon)
    response = []
    caracteristicas = taxon.nom_cites_iucn_ambiente_prioritaria({iucn_ws: true})
    caracteristicas[:grupo1] << taxon.tipo_distribucion

    caracteristicas.each do |g, valores|
      tiene_valor = false
      valores.map{ |v| v.values }.flatten.each do |valor|
        response << "<span class='btn-title caracteristica-distribucion-ambiente-taxon' title='#{valor}'><i class ='#{valor.estandariza}-ev-icon'></i></span>"
        tiene_valor = true
      end

      response << "&nbsp;"*2 if tiene_valor  # Espacios para seprar las categorias
    end

    # Pesquerias sustentables del semaforo
    if pez = taxon.pez

      if pez.con_estrella
        response << "<span class='btn-title caracteristica-distribucion-ambiente-taxon pmc' title='<a href=\"/peces\" class=\"btn btn-link\" target=\"_blank\">Especie con certificación perteneciente al semáforo de consumo marino responsable</a>' data-especie-id='#{taxon.id}'><i class ='peces-mariscos-comerciales-certificacion-ev-icon'></i></span>"
      else
        response << "<span class='btn-title caracteristica-distribucion-ambiente-taxon pmc' title='<a href=\"/peces\" class=\"btn btn-link\" target=\"_blank\">Especie perteneciente al semáforo de consumo marino responsable</a>' data-especie-id='#{taxon.id}'><i class ='peces-mariscos-comerciales-ev-icon'></i></span>"
      end
    end

    response.any? ? response.join.html_safe : ""
  end

# REVISADO: Pone la simbologia en la ficha de la especie
  def ponCaracteristicaDistribucionAmbienteTodos
    response = {}

    def creaSpan(recurso)
      nombre = recurso.descripcion
      icono  = "<i class = '#{recurso.descripcion.parameterize}-ev-icon'></i>"

      "<span title='#{nombre}' class='btn-title alt='#{nombre}'>#{icono}</span>"
    end

    Catalogo.nom_cites_iucn_todos.each do |k, valores|
      valores.each do |edo|
        response[k] ||=[]
        response[k] << creaSpan(edo)
      end
    end

    TipoDistribucion.distribuciones.each do |tipoDist|
      response[:tipoDistribucion] ||= []
      response[:tipoDistribucion] << creaSpan(tipoDist)
    end

    Catalogo.ambiente_todos.each do |amb|
      response[:ambiente] ||=[]
      response[:ambiente] << creaSpan(amb)
    end

    Catalogo.prioritaria_todas.each do |prior|
      response[:prioritaria] ||=[]
      response[:prioritaria] << creaSpan(prior)
    end

    response
  end

  def ponBotonEditaIDNaturalista
    button_tag("Cambia URL Naturalista <span class='glyphicon glyphicon-pencil' aria-hidden='true'></span>".html_safe,
               id: 'cambiar_id_naturalista' ,  "data-toggle" => "modal", "data-target" => "#modal_cambia_id_naturalista" , :class => "btn btn-link btn-title", :title=>'Cambiar URL de Naturalista')
  end


  def esSinonimo (taxon)
    e = (taxon.instance_of? NombreComun) ? Especie.find(taxon.id).estatus : taxon.estatus #Debido a que se reemplaza
    # el id de NombreComun
    n = e == 1 ? "<s>#{taxon.nombre_cientifico}</s>" : taxon.nombre_cientifico
    n.html_safe
  end


  def imprime_media_bdi(item, type)
    copyright = "BDI - CONABIO"
    case type
    when 'photo'
      link_to("<img src='#{item.medium_url}' class='rounded-sm border-light' />".html_safe, '',
              "data-toggle" => "modal", "data-target" => "#modal_reproduce", :class => "m-1 modal-buttons",
              "data-type" => 'photo',
              "data-copyright" => copyright,
              "data-url" => item.medium_url,
              "data-author" => item.native_realname,
              "data-locality" =>  "No disponible",
              "data-observation"=> item.native_page_url
      )
    when 'video' # Datos fasos por ahora
      link_to("<img src='#{item.preview_img}' class='rounded-sm border-light' />".html_safe, '',
              "data-toggle" => "modal", "data-target" => "#modal_reproduce", :class => "m-1 modal-buttons",
              "data-type" => 'video',
              "data-copyright" => item.licencia.present? ? "<a href='#{item.licencia}' target='_blank'>#{copyright}</a>" : copyright,
              "data-observation"=> item.href_info,
              "data-url" => item.url_acces,
              "data-author" => item.autor,
              "data-locality" =>  item.localidad.present? ? item.localidad : "No disponible",
              "data-state" =>  item.municipio.present? ? item.municipio : nil
      )
    end
  end

  def imprimeMediaCornell(item,type)
    copyright = "Macaulay Library at The Cornell Lab of Ornithology"
    case type
    when 'photo'
      link_to("<img src='#{item['mlBaseDownloadUrl']}#{item['assetId']}/320' />".html_safe, '',
              "data-toggle" => "modal", "data-target" => "#modal_reproduce", :class => "m-1 modal-buttons",
              "data-observation"=> item['citationUrl'], "data-url" => "#{item['mlBaseDownloadUrl']}#{item['assetId']}/900",
              "data-type" => 'photo', "data-author" => item['userDisplayName'], "data-date" => item['obsDtDisplay']||='',
              "data-country" => item['countryName']||='', "data-state" => item['subnational1Name']||='', "data-locality" => item['locName']||='', "data-copyright" => copyright)
    when 'video'
      link_to("<img src='#{item['mlBaseDownloadUrl']}#{item['assetId']}/thumb' />".html_safe, '',
              "data-toggle" => "modal", "data-target" => "#modal_reproduce", :class => "m-1 modal-buttons",
              "data-observation"=> item['citationUrl'], "data-url" => "#{item['mlBaseDownloadUrl']}#{item['assetId']}/video", "data-type" => 'video',
              "data-author" => item['userDisplayName'], "data-date" => item['obsDtDisplay']||='', "data-country" => item['countryName']||='',
              "data-state" => item['subnational1Name']||='', "data-locality" => item['locality']||='', "data-copyright" => copyright)
    when 'audio'
      link_to("<img src='#{item['mlBaseDownloadUrl']}#{item['assetId']}/poster' />".html_safe, '', "data-toggle" => "modal",
              "data-target" => "#modal_reproduce", :class => "m-1 modal-buttons", "data-observation"=> item['citationUrl'],
              "data-url" => "#{item['mlBaseDownloadUrl']}#{item['assetId']}/audio", "data-type" => 'audio',
              "data-author" => item['userDisplayName'], "data-date" => item['obsDtDisplay']||='', "data-country" => item['countryName']||='',
              "data-state" => item['subnational1Name']||='', "data-locality" => item['locality']||='', "data-copyright" => copyright)
    end
  end

  def imprime_canto(item)
    copyright = "Xeno Canto: Sharing bird sounds from around the world"
    link_to image_tag("https:#{item['sono']['med']}"), "",  class: "m-1 modal-buttons", data: {
        toggle: "modal",
        target: "#modal_reproduce",
        type: "video",
        url: "#{item['file']}",
        observation: "https://#{item['url']}",
        file: "#{item['file']}",
        generic_name: item['gen'],
        specific_name: item['sp'],
        subspecies_name: item['ssp'],
        english_name: item['en'],
        country_recording: item['cnt'],
        locality: item['loc'],
        # url: item['url'], #
        file_name: item['file-name'],
        license: item['lic'],
        length: item['length'],
        time: item['time'],
        date: item['date'],
        remarks: item['rmk'],
        copyright: copyright,
        author: item["rec"]
    }
  end

  def imprime_img_tropicos(item)
    copyright = "Missouri Botanical Garden"
    link_to("<img src='#{item['DetailJpgUrl']}'/>".html_safe, '', "data-toggle" => "modal",
            "data-target" => "#modal_reproduce",
            :class => "m-1 modal-buttons",
            "data-observation"=> item['DetailUrl'],
            "data-url" => item['DetailJpgUrl'],
            "data-type" => 'photo',
            "data-author" => item['Photographer'] ||= copyright,
            "data-copyright" => item['Copyright'] ||= copyright,
            "data-title" => item['NameText'] ||= '',
            "data-locality" => item['PhotoLocation'] ||= 'No disponible',
            "data-state" => '', "data-country" => '',
            "data-date" => item['PhotoDate'] ||= '',
            "data-tipodeimagen" => item['ImageKindText'],
            "data-caption" => item['Caption'],
            "data-descripcion" => item['ShortDescription']
    )
  end

# Validar si texto es una URL, si lo es, regresa la liga en HTML, si no, regresa el mismo texto
  def es_url_valido(text)
    begin
      url = URI.parse(text.to_s)
      url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS) ? resultado = "<a target='_blank' href='#{text}'>#{text}</a>".html_safe : resultado = text
    rescue
      resultado = text
    end
    resultado
  end

  def dejaComentario
    link_to("comentario, sugerencia o corrección <span class='glyphicon glyphicon-comment'></span>".html_safe, new_especie_comentario_path(@especie))
  end

  def cargandoEspera
    "<p>Cargando... por favor, espera</p><div class='spinner-border text-secondary' role='status'><span class='sr-only'>Cargando...</span></div>".html_safe
  end

# Es un select con los demas albumes de bdi para ver fotos directamente
  def albumes_bdi
    html = "<div class='dropdown'><button class='btn btn-light btn-sm dropdown-toggle text-primary' type='button' data-toggle='dropdown' aria-expanded='false'>Explora más fotos en los álbumes del BDI</button><div class='dropdown-menu'>"

    @albumes.each do |a|
      html << "<a class='dropdown-item' target='_blank' href=\"#{a[:url]}\">#{a[:nombre_album]} (#{a[:num_assets]} fotos) &middot; <i class='fa fa-external-link'></i></a>"
    end

    html << "</div></div>"
    html.html_safe
  end

end
