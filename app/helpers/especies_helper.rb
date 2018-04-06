module EspeciesHelper

  def tituloNombreCientifico(taxon, params={})

    nombre = if taxon.x_nombre_comun_principal.present?
               taxon.x_nombre_comun_principal
             else
               begin  # Es con un try porque no toda consulta le hace un join a adicionales
                 taxon.nombre_comun_principal
               rescue  # hacemos el join a adicionales
                 if a = taxon.adicional
                   a.nombre_comun_principal
                 else
                   ''
                 end
               end
             end.try(:capitalize)
  
    if I18n.locale.to_s == 'es-cientifico'
      if taxon.especie_o_inferior?   # Las especies llevan otro tipo de formato en nombre
        if params[:title]
          "#{taxon.nombre_cientifico} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}"
        elsif params[:link]
          if taxon.x_nombre_comun_principal.present?
            "#{ponItalicas(taxon,true)} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]} ----------> #{taxon.x_nombre_comun_principal.capitalize}".html_safe
          else
            "#{ponItalicas(taxon,true)} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          "#{ponItalicas(taxon)} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el nombre'.html_safe
        end
      else
        if params[:title]
          "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        elsif params[:link]
          "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{link_to("#{taxon.nombre_cientifico}", especie_path(taxon))} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        elsif params[:show]
          "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el nombre'.html_safe
        end
      end

    else   #vista general

      if taxon.especie_o_inferior?  # Las especies llevan otro tipo de formato en nombre
        if params[:title]
          nombre.present? ? "#{nombre} (#{taxon.nombre_cientifico})".html_safe : taxon.nombre_cientifico
        elsif params[:link]
          nombre.present? ? "<h5>#{nombre}</h5><h5>#{link_to(ponItalicas(taxon).html_safe, especie_path(taxon))}</h5>" : "<h5>#{ponItalicas(taxon,true)}</h5>"
        elsif params[:show]
          nombre.present? ? "#{nombre} (#{ponItalicas(taxon)})".html_safe : ponItalicas(taxon).html_safe
        else
          'Ocurrio un error en el nombre'.html_safe
        end
      else
        if params[:title]
          nombre.present? ? "#{nombre} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico})".html_safe :
              "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico}".html_safe
        elsif params[:link]
          nombre.present? ? "<h5>#{nombre}</h5><h5>#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{link_to("#{taxon.nombre_cientifico}", especie_path(taxon))}</h5>".html_safe : "<h5>#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{link_to(taxon.nombre_cientifico, especie_path(taxon))}</h5>".html_safe
        elsif params[:show]
          nombre.present? ? "#{nombre} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico})".html_safe :
              "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico}".html_safe
        else
          'Ocurrio un error en el nombre'.html_safe
        end
      end
    end
  end

  # Para separar SÓLO las italicas EN el nombre cientifico y la categoria taxonomica
  def ponItalicas(taxon, con_link = false)
    italicas = taxon.nombre_cientifico.gsub('subsp.','</i>subsp.<i>').gsub('var.','</i>var.<i>').gsub('f.','</i>f.<i>').
        gsub('subvar.','</i>subvar.<i>').gsub('subf.','</i>subf.<i>')

    if con_link
      "<a href=\"/especies/#{taxon.id}\"><i>#{italicas}</i></a>"
    else
      "<i>#{italicas}</i>"
    end
  end

  def enlacesDeTaxonomia(taxa, nuevo=false)        #ancestros del titulo
    enlaces = "<table width=\"1000\" id=\"enlaces_taxonomicos\"><tr><td>"

    taxa.ancestor_ids.push(taxa.id).each do |ancestro|
      if taxa.id == ancestro
        if nuevo
          e=Especie.find(ancestro)
          enlaces+= "#{link_to(image_tag(e.foto_principal, :alt => e.nombre_cientifico, :title => e.nombre_cientifico, :width => '40px'), e)} #{link_to(e.nombre, e)} (#{e.categoria_taxonomica.nombre_categoria_taxonomica}) > ?   "
        else
          enlaces+= "#{link_to(image_tag(taxa.foto_principal, :alt => taxa.nombre_cientifico, :title => taxa.nombre_cientifico, :width => '40px'), e)} #{taxa.nombre} (#{taxa.categoria_taxonomica.nombre_categoria_taxonomica}) > "
        end
      else
        e = Especie.find(ancestro)
        enlaces+= "#{link_to(image_tag(e.foto_principal, :alt => e.nombre_cientifico, :title => e.nombre_cientifico, :width => '40px'), e)} #{link_to(e.nombre, e)} (#{e.categoria_taxonomica.nombre_categoria_taxonomica}) > "
      end
    end
    "#{enlaces[0..-3]}</td></tr></table>".html_safe
  end

  def construye_arbol(taxon, params={})
    nodos = "<li id='nodo_#{taxon.id}' class='links_arbol'>"
    nodos << "#{link_to("<span class='glyphicon glyphicon-plus' aria-hidden='true' id='span_#{taxon.id}'></span>".html_safe, '',
                        :id =>"link_#{taxon.id}", :class => 'sub_link_taxon btn btn-sm btn-link', :onclick => 'return despliegaOcontrae(this.id);')}"
    nodos << " #{tituloNombreCientifico(taxon, :link => true)}"

    nodos << '</li>' if params[:son_hojas]
  end

  def accionesEnlaces(modelo, accion, index=false)
    case accion
      when 'especies'
        "#{link_to(image_tag('app/32x32/zoom.png'), modelo)}
        #{link_to(image_tag('app/32x32/edit.png'), "/#{accion}/#{modelo.id}/edit")}
        #{link_to(image_tag('app/32x32/trash.png'), "/#{accion}/#{modelo.id}", method: :delete, data: { confirm: "¿Estás seguro de eliminar esta #{accion.singularize}?" })}"
      when 'listas'
        index ?
            "#{link_to(image_tag('app/32x32/full_page.png'), modelo)}
            #{link_to(image_tag('app/32x32/edit_page.png'), "/#{accion}/#{modelo.id}/edit")}
            #{link_to(image_tag('app/32x32/download_page.png'), "/listas/#{modelo.id}.csv")}
            #{link_to(image_tag('app/32x32/delete_page.png'), "/#{accion}/#{modelo.id}", method: :delete, data: { confirm: "¿Estás seguro de eliminar esta #{accion.singularize}?" })}" :
            "#{link_to(image_tag('app/32x32/full_page.png'), modelo)}
            #{link_to(image_tag('app/32x32/edit_page.png'), "/#{accion}/#{modelo.id}/edit")}
            #{link_to(image_tag('app/32x32/add_page.png'), new_lista_path)}
            #{link_to(image_tag('app/32x32/download_page.png'), "/listas/#{modelo.id}.csv")}
            #{link_to(image_tag('app/32x32/delete_page.png'), "/#{accion}/#{modelo.id}", method: :delete, data: { confirm: "¿Estás seguro de eliminar esta #{accion.singularize}?" })}"
    end
  end

  # Nombres comunes con su bibliografia como referencia
  def dameNomComunesBiblio(taxon)
    nombres_comunes = {}

    taxon.especies_regiones.each do |er|

      # Parte de los nombres comunes con la bibliografia
      er.nombres_regiones.where(:region_id => er.region_id).each do |nombre|
        if nombres_comunes[nombre.nombre_comun.id].nil?
          # Nombre comun con su lengua
          nombres_comunes[nombre.nombre_comun.id] = { nombre: nombre.nombre_comun.nombre_comun.capitalize, lengua: nombre.nombre_comun.lengua.downcase }

          # Para una o mas bibliografias
          nombres_comunes[nombre.nombre_comun.id][:bibliografia] = []
          nombre.nombres_regiones_bibliografias.where(:region_id => nombre.region_id, :nombre_comun_id => nombre.nombre_comun_id).each do |biblio|
            nombres_comunes[nombre.nombre_comun.id][:bibliografia] << biblio.bibliografia.cita_completa
          end
        end
      end  # End each nombre
    end  # End each especie_region

    # Ordena por el nombre
    nombres_comunes.sort_by {|k,v| v[:nombre]}
  end

  # La distribucion agrupada por el tipo de region
  def dameDistribucion(taxon)
    distribucion = {}

    taxon.especies_regiones.each do |er|
      tipo_reg = er.region.tipo_region
      nivel_numero = "#{tipo_reg.nivel1}#{tipo_reg.nivel2}#{tipo_reg.nivel3}"
      nivel = TipoRegion::REGION_POR_NIVEL[nivel_numero]
      distribucion[nivel] = [] if distribucion[nivel].nil?

      # Evita poner ND como una region
      next if er.region.nombre_region.downcase == 'nd'

      # Para poner los estados faltantes provenientes de municipios u otros tipos de regiones
      if nivel_numero.to_i > 110
        er.region.ancestors.joins(:tipo_region).where('nivel1 = ? AND nivel2 = ? AND nivel3= ?', 1,1,0).each do |r|
          # Asigno el estado de una region menor a 110
          distribucion[TipoRegion::REGION_POR_NIVEL['110']] = [] if distribucion[TipoRegion::REGION_POR_NIVEL['110']].nil?
          distribucion[TipoRegion::REGION_POR_NIVEL['110']] << r.nombre_region
        end
      end

      distribucion[nivel] << er.region.nombre_region
    end

    # Para quitar el presente en Mexico, si es que tiene alguna distribucion estatal, municipal, etc.
    presente = TipoRegion::REGION_POR_NIVEL['100']
    if distribucion.count > 1 && distribucion.key?(presente)
      distribucion.delete(presente)
    end

    # Ordena por el titulo del tipo de region
    distribucion.sort
  end

  # REVISADO: Una misma funcion para sinonimos u homnimos
  def dameSinonimosUhomonimos(taxon, opciones={})
    def creaContenedor(recurso, opciones={})
      "<strong>#{opciones[:tipo_recurso]}: </strong><small>#{recurso.join(', ')}</small>"
    end

    def creaLista(recurso, opciones={})
      "<p><strong>#{opciones[:tipo_recurso]} </strong></p><ul>#{recurso.join('')}</ul>"
    end

    ids = taxon.especies_estatus.send(opciones[:tipo_recurso].estandariza).sinonimos.map(&:especie_id2)
    return '' unless ids.any?
    taxones = Especie.find(ids)

    if opciones[:tab_catalogos]
      recurso = taxones.map{ |t| "<li>#{tituloNombreCientifico(t, show: true)}</li>" }
      creaLista(recurso, opciones).html_safe
    else
      recurso = taxones.map{ |t| tituloNombreCientifico(t, show: true) }
      creaContenedor(recurso, opciones).html_safe
    end
  end

  def dameEstatus(taxon, opciones={})




    estatus_a = []



=begin
    ids = taxon.especies_estatus.homonimos.map(&:especie_id2)
    #return '' unless ids.any?
    taxones = Especie.find(ids)
    recurso = taxones.map{ |t| tituloNombreCientifico(t, show: true) }
    opciones[:tab_catalogos] ? creaLista(recurso, 'Homónimos') : creaContenedor(recurso, 'Homónimos')


    taxon.especies_estatus.order('estatus_id ASC').each do |estatus|     # Checa si existe alguna sinonimia
      begin
        taxSinonimo = Especie.find(estatus.especie_id2)
      rescue
        break
      end

      if opciones[:tab_catalogos]
        if taxon.estatus == 2                                              # Valido
          est = "<li>#{tituloNombreCientifico(taxSinonimo, show: true, con_icono: false)}"
          obs = estatus.observaciones.present? ? "<br> <b>Observaciones: </b> #{estatus.observaciones}</li>" : '</li>'
          estatus_a << "#{est} #{obs}"
        elsif taxon.estatus == 1 && taxon.especies_estatus.length == 1      # Sinonimo, en teoria ya no existe esta vista
          est = tituloNombreCientifico(taxSinonimo, :link => true)
          obs = estatus.observaciones.present? ? "<br> <b>Observaciones: </b> #{estatus.observaciones}" : ''
          estatus_a << "#{est} #{obs}"
        else
          estatus_a << '<p><strong>Existe un problema con el estatus del nombre científico de este taxón</strong></p>'
        end
      else   # En esta no los pongo en lista
        if taxon.estatus == 2                                              # Valido
          estatus_a << tituloNombreCientifico(taxSinonimo, show: true, con_icono: false)
        elsif taxon.estatus == 1 && taxon.especies_estatus.length == 1      # Sinonimo, en teoria ya no existe esta vista
          estatus_a << tituloNombreCientifico(taxSinonimo, :link => true)
        else
          estatus_a << '<p><strong>Existe un problema con el estatus del nombre científico de este taxón</strong></p>'
        end
      end
    end

    if estatus_a.present?
      if opciones[:tab_catalogos]
        titulo = taxon.estatus == 2 ? '<strong>Sinónimos: </strong>' : '<strong>Aceptado como: </strong>'
        taxon.estatus == 2 ? titulo << "<p><ul>#{estatus_a.map{|estat| estat.gsub('sinónimo','')}.join('')}</ul></p>" : "<p>#{titulo}#{estatus_a.join('')}</p>"
      else
        taxon.estatus == 2 ? "<strong>Sinónimos: </strong><small>#{estatus_a.map{|estat| estat.gsub('sinónimo','')}.join(', ')}</small>" : "<strong>Aceptado como: </strong>#{estatus_a.join(', ')}"
      end
    else
      ''
    end
=end
  end

  # REVISADO: Pone las respectivas categorias de riesgo, distribucion y ambiente en el show de especies; pestaña de catalogos
  def dameCaracteristica(taxon)
    caracteristicas = [taxon.tipo_distribucion(tab_catalogos: true), taxon.nom_cites_iucn_ambiente_prioritaria({iucn_ws: true})].flatten
    html = ''

    def creaCaracteristica(nom_caract, valores)
      lista = valores.map{|c| "<li>#{c}</li>"}
      "<p><strong>#{nom_caract}</strong><ul>#{lista.join('')}</ul></p>"
    end

    caracteristicas.each do |caract|
      nom_caract = caract.keys.join('')
      valores = caract.values.flatten
      next unless valores.any?
      html << creaCaracteristica(nom_caract, valores)
    end

    html.html_safe
  end

  # REVISADO: Pone las respectivas categorias de riesgo, distribucion y ambiente en el show de especies
  def ponCaracteristicaDistribucionAmbienteTaxon(taxon)
    response = []
    caracteristicas = [taxon.tipo_distribucion.map{|h| h.values}, taxon.nom_cites_iucn_ambiente_prioritaria({iucn_ws: true}).map{|h| h.values}].flatten

    caracteristicas.each{ |x|
      response << "<span class='btn-title' title='#{x}'><i class ='#{x.estandariza}-ev-icon'></i></span>"
    }

    response << "<small class='glyphicon glyphicon-question-sign text-primary ' onclick=\"$('#panelCaracteristicaDistribucionAmbiente').toggle(600, 'easeOutBounce')\" style='cursor: pointer; margin-left: 10px;'></small>" if response.any?
    response.join.html_safe
  end

  # REVISADO: Pone la simbologia en la ficha de la especie
  def ponCaracteristicaDistribucionAmbienteTodos
    response = {}

    def creaSpan(recurso)
      nombre = recurso.descripcion
      icono  = "<i class = '#{recurso.descripcion.parameterize}-ev-icon'></i>"
      "<span title='#{nombre}' class='btn-title' alt='#{nombre}'>#{icono}</span>"
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
    button_tag("Cambia URL Naturalista <span class='glyphicon glyphicon-pencil' aria-hidden='true'></span>".html_safe, id: 'cambiar_id_naturalista' ,  "data-toggle" => "modal", "data-target" => "#modal_cambia_id_naturalista" , :class => "btn btn-link btn-title", :title=>'Cambiar URL de Naturalista')
  end

  def dameEspecieBibliografia(taxon)
    biblio=''
    taxon.especies_bibliografias.each do |bib|
      biblio_comp = bib.bibliografia.cita_completa
      biblio+="<li>#{bib.bibliografia.cita_completa}</li>" if biblio_comp.present?
    end
    biblio.present? ? "<b>Bibliografía:</b><ul>#{biblio}</ul>" : biblio
  end

  def dameTaxonesInferiores(taxon)
    hijos=''
    child_ids = taxon.child_ids
    return hijos unless child_ids.present?

    Especie.datos_basicos.caso_rango_valores('especies.id', child_ids.join(',')).order('nombre_cientifico ASC').each do |subTaxon|
      hijos << "<li>#{tituloNombreCientifico(subTaxon, :link => true)}</li>"
    end
    hijos.present? ? "<fieldset><legend class='leyenda'>Taxones Inferiores</legend><div id='hijos'><ul>#{hijos}</div></fieldset></ul>" : hijos
  end

  def photo_providers(licensed=false, photo_providers=nil)
    providers=CONFIG.photo_providers ||= photo_providers || %W(conabio flickr eol wikimedia)
    html='<ul>'
    providers.each do |prov|
      prov=prov.to_s.downcase

      case prov
        when 'flickr'
          html+="<li>#{link_to("<span>De #{prov.titleize}</span>".html_safe, "##{prov}_taxon_photos")}</li>"
        when 'wikimedia'
          html+="<li>#{link_to("<span>De #{prov.titleize} Commons</span>".html_safe, "##{prov}_taxon_photos")}</li>"
        when 'eol', 'conabio'
          html+="<li>#{link_to("<span>De #{prov.upcase}</span>".html_safe, "##{prov}_taxon_photos")}</li>"
        when 'inat_obs'
          title=licensed ? "#{t(:from_licensed_site_observations, :site_name => SITE_NAME_SHORT)}" :
              "#{t(:from_your_site_observations, :site_name => SITE_NAME_SHORT)}"
          html+="<li>#{link_to("<span>#{title}</span>".html_safe, "##{prov}_taxon_photos")}</li>"
      end
    end
    "#{html}</ul>".html_safe
  end

  def esSinonimo (taxon)
    e = (taxon.instance_of? NombreComun) ? Especie.find(taxon.id).estatus : taxon.estatus #Debido a que se reemplaza
    # el id de NombreComun
    n = e == 1 ? "<s>#{taxon.nombre_cientifico}</s>" : taxon.nombre_cientifico
    n.html_safe
  end

  def imprimeMediaCornell(item,type)
    case type
      when 'photo'
        link_to("<img src='#{item['mlBaseDownloadUrl']}/#{item['assetId']}/320' />".html_safe, '', "data-toggle" => "modal", "data-target" => "#modal_reproduce", :class => "btn btn-link btn-title modal-buttons", "data-observation"=> item['citationUrl'], "data-url" => "#{item['mlBaseDownloadUrl']}/#{item['assetId']}/900", "data-type" => 'photo', "data-author" => item['userDisplayName'], "data-date" => item['obsDtDisplay']||='', "data-country" => item['countryName']||='', "data-state" => item['subnational1Name']||='', "data-locality" => item['locName']||='')
      when 'video'
        link_to("<img src='#{item['mlBaseDownloadUrl']}#{item['assetId']}/thumb' />".html_safe, '', "data-toggle" => "modal", "data-target" => "#modal_reproduce", :class => "btn btn-link btn-title modal-buttons", "data-observation"=> item['citationUrl'], "data-url" => "#{item['mlBaseDownloadUrl']}/#{item['assetId']}/video", "data-type" => 'video', "data-author" => item['userDisplayName'], "data-date" => item['obsDtDisplay']||='', "data-country" => item['countryName']||='', "data-state" => item['subnational1Name']||='', "data-locality" => item['locality']||='')
      when 'audio'
        link_to("<img src='#{item['mlBaseDownloadUrl']}#{item['assetId']}/poster' />".html_safe, '', "data-toggle" => "modal", "data-target" => "#modal_reproduce", :class => "btn btn-link btn-title modal-buttons", "data-observation"=> item['citationUrl'], "data-url" => "#{item['mlBaseDownloadUrl']}/#{item['assetId']}/audio", "data-type" => 'audio', "data-author" => item['userDisplayName'], "data-date" => item['obsDtDisplay']||='', "data-country" => item['countryName']||='', "data-state" => item['subnational1Name']||='', "data-locality" => item['locality']||='')
    end
  end

end
