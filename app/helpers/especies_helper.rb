module EspeciesHelper

  def tituloNombreCientifico(taxon, params={})
    if I18n.locale.to_s == 'es-cientifico'
      if taxon.species_or_lower?(taxon.try(:nombre_categoria_taxonomica))   # Las especies llevan otro tipo de formato en nombre
        if params[:title]
          "#{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]}"
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{taxon.nombre_comun} (<i>#{link_to(taxon.nombre_cientifico, especy_path(taxon))}</i> #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe
          else
            "<i>#{link_to(taxon.nombre_cientifico, especy_path(taxon))}</i> #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          "<i>#{taxon.nombre_cientifico}</i> #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      else
        if params[:title]
          "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{taxon.nombre_comun} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.nombre_categoria_taxonomica} #{link_to(taxon.nombre_cientifico, especy_path(taxon))} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe
          else
            "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{link_to("#{taxon.nombre_cientifico}", especy_path(taxon))} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      end

    else   #vistas menos cientificas
      if taxon.species_or_lower?(taxon.try(:nombre_categoria_taxonomica))   # Las especies llevan otro tipo de formato en nombre
        if params[:title]
          taxon.nombre_comun_principal.present? ? "#{taxon.nombre_comun_principal.humanizar} (#{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
              "#{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]}"
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{link_to(taxon.nombre_comun.humanizar, especy_path(taxon))} (<i>#{taxon.nombre_cientifico}</i> #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe
          else
            taxon.nombre_comun_principal.present? ? "#{link_to(taxon.nombre_comun_principal.humanizar, especy_path(taxon))} (<i>#{taxon.nombre_cientifico}</i> #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
                "<i>#{link_to(taxon.nombre_cientifico, especy_path(taxon))}</i> #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          taxon.nombre_comun_principal.present? ? "#{taxon.nombre_comun_principal.humanizar} (<i>#{taxon.nombre_cientifico}</i> #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
              "<i>#{taxon.nombre_cientifico}</i> #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      else
        if params[:title]
          taxon.nombre_comun_principal.present? ? "#{taxon.nombre_comun_principal.humanizar} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
              "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{link_to(taxon.nombre_comun.humanizar, especy_path(taxon))} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe
          else
            taxon.nombre_comun_principal.present? ? "#{link_to(taxon.nombre_comun_principal.humanizar, especy_path(taxon))} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
                "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{link_to("#{taxon.nombre_cientifico}", especy_path(taxon))} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          taxon.nombre_comun_principal.present? ? "#{taxon.nombre_comun_principal.humanizar} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
              "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      end
    end
  end

  def datos_principales(taxon, opciones={})
    datos = dameNomComunes(taxon)
    datos << dameStatus(taxon, opciones)
    datos << '<br>' << dameDistribucion(taxon) << ' - '
    datos << dameCaracteristica(taxon)
    datos.html_safe
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

  def enlacesDelArbol(taxon, conClick=nil)     #cuando carga la pagina
    nodos = "<li id='nodo_#{taxon.id}' class='links_arbol'>"
    nodos << "#{link_to("<span class='glyphicon glyphicon-plus' aria-hidden='true' id='span_#{taxon.id}'></span>".html_safe, '', :id =>"link_#{taxon.id}", :class => 'sub_link_taxon btn btn-sm btn-link', :onclick => "$('#span_#{taxon.id}').toggleClass('glyphicon-plus');$('#span_#{taxon.id}').toggleClass('glyphicon-minus');return despliegaOcontrae(this.id);")}"
    nodos << "#{image_tag(taxon.foto_principal, :alt => taxon.nombre_cientifico, :title => taxon.nombre_cientifico, :class => 'img-thumbnail img-circle', :style => 'width: 50px; height: 50px;')}"
    nodos << " #{tituloNombreCientifico(taxon, :link => true)}"
    #Deja los nodos abiertos para que esten anidados (si conClick es falso)
    conClick.present? ? "<ul>#{nodos}</li></ul>" : "<ul>#{nodos}"
  end

  def arbolTaxonomico(taxon, accion=false)
    # Si es para desplegar o contraer
    if accion
      nodo = ''
      if taxon.is_root? && taxon.categoria_taxonomica.nombre_categoria_taxonomica.downcase == 'reino'
        #Me aseguro que sean reinos
        categorias_reinos = CategoriaTaxonomica.where(:nivel1 => 1, :nivel2 => 0, :nivel3 => 0, :nivel4 => 0).map(&:id).join(',')
        # Junto los reinos para que los taxones que se repiten en mismos reinos de diferentes bases esten como descendientes
        reinos = Especie.caso_rango_valores('categoria_taxonomica_id', categorias_reinos).where(:nombre => taxon.nombre).map{|r| r.child_ids}.flatten

        Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.caso_rango_valores('especies.id', reinos.join(',')).each do |children|
          nodo+= enlacesDelArbol(children, true)
        end
      else
        Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.caso_rango_valores('especies.id', taxon.child_ids.join(',')).each do |children|
          nodo+= enlacesDelArbol(children, true)
        end
      end
      nodo

    else
      if taxon.try(:is_root?) || taxon.nil?  # Si es root o es el arbol del index
        arbolCompleto = ''
        reino = CategoriaTaxonomica.where(:nivel1 => 1, :nivel2 => 0, :nivel3 => 0, :nivel4 => 0).first
        Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.where(:categoria_taxonomica_id => reino).each do |t|
          arbolCompleto << "<ul class=\"nodo_mayor\">" + enlacesDelArbol(t) + '</li></ul></ul>'
        end
        # Pone los reinos en una lista separada cada uno
        arbolCompleto

      else
        tags = ''
        arbolCompleto = "<ul class=\"nodo_mayor\">"
        contadorNodos = 0

        Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.caso_rango_valores('especies.id', (taxon.ancestor_ids + [taxon.id]).join(',')).each do |ancestro|
          arbolCompleto << enlacesDelArbol(ancestro)
          contadorNodos+= 1
        end

        contadorNodos.times {tags << '</li></ul>'}
        arbolCompleto + tags + '</ul>'
      end
    end
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
            #{link_to(image_tag('app/32x32/add_page.png'), new_lista_url)}
            #{link_to(image_tag('app/32x32/download_page.png'), "/listas/#{modelo.id}.csv")}
            #{link_to(image_tag('app/32x32/delete_page.png'), "/#{accion}/#{modelo.id}", method: :delete, data: { confirm: "¿Estás seguro de eliminar esta #{accion.singularize}?" })}"
    end
  end

  def busquedas(iterador)
    opciones=''
    iterador.each do |valor, nombre|
      opciones+="<option value=\"#{valor}\">#{nombre}</option>"
    end
    opciones
  end

  def checkboxTipoDistribucion
    checkBoxes = ''
    quitar_distribuciones = %w(actual original)

    TipoDistribucion.all.order('descripcion ASC').map(&:descripcion).map{ |dis| I18n.transliterate(dis).downcase }.uniq.each do |tipoDist|
      next if quitar_distribuciones.include?(tipoDist)      #Quita algunos tipos de distribucion que no son validos
      checkBoxes+="<label class='checkbox' style='margin: 0px 10px;'>#{check_box_tag("dist[]", t('distribucion.'+tipoDist.gsub(' ', '_')), false, :class => :busqueda_atributo_checkbox)} #{t('distribucion.'+tipoDist.gsub(' ', '_'))}</label>"
      end
    checkBoxes.html_safe
  end

  def checkboxEstadoConservacion
    checkBoxes=''
    Catalogo.nom_cites_iucn_todos.each do |k, valores|
      checkBoxes+= "<br><b>#{t(k)}</b>"
      contador=0

      valores.each do |edo|
        #checkBoxes+='<br>' if contador%2 == 0    #para darle un mejor espacio
        checkBoxes+="<label class='checkbox' style='margin: 0px 10px;'>#{check_box_tag('edo_cons[]', edo, false, :class => :busqueda_atributo_checkbox)} #{edo}</label>"
        contador+=1
      end
    end
    checkBoxes.html_safe
  end

  def checkboxCategoriaTaxonomica
    checkBoxes=''
    contador=0

    CategoriaTaxonomica.order('nivel1, nombre_categoria_taxonomica ASC').map(&:nombre_categoria_taxonomica).uniq.each do |cat|
      #checkBoxes+='<br>' if contador%4 == 0    #para darle un mejor espacio
      checkBoxes+="<label class='checkbox' style='margin: 0px 10px;'>#{check_box_tag('cat[]', cat, false, :class => :busqueda_atributo_checkbox)} #{cat}</label>"
      contador+=1
    end
    checkBoxes.html_safe
  end

  def checkboxValidoSinonimo (busqueda=nil)
    checkBoxes=''
    Especie::ESTATUS.each do |e|

      checkBoxes += case busqueda
                      when "BBShow" then "<label class='checkbox-inline'>#{check_box_tag('estatus[]', e.first, false, :class => :busqueda_atributo_checkbox, :onChange => '$(".checkBoxesOcultos").empty();$("#panelValidoSinonimoBasica  :checked ").attr("checked",true).clone().appendTo(".checkBoxesOcultos");')} #{e.last}</label>"
                     else "<label class='checkbox-inline'>#{check_box_tag('estatus[]', e.first, false, :class => :busqueda_atributo_checkbox)} #{e.last}</label>"
                   end
    end
    checkBoxes.html_safe
  end

  def dameNomComunes(taxon)
    nombres_comunes = ''
    nombres = taxon.nombres_comunes.where("nombre_comun != '#{taxon.nombre_comun_principal}'").map {|nc| {nc.lengua => nc.nombre_comun.humanizar}}.uniq
    agrupa_nombres = nombres.reduce({}) {|h, pairs| pairs.each {|k, v| (h[k] ||= []) << v}; h}
    keys = agrupa_nombres.keys.sort
    keys.each do |k|
      nombres_comunes << "#{agrupa_nombres[k].join(', ')} <span style='font-size:9px;'>(#{k})</span> / "
    end
    nombres_comunes.present? ? "<p>#{nombres_comunes[0..-3]}</p>" : nombres_comunes
  end

  def dameDistribucion(taxon)
    dist = []
    taxon.especies_regiones.each do |reg|
      dist << reg.tipo_distribucion.descripcion if reg.tipo_distribucion
    end

    dist.any? ? dist.uniq.join(', ') : ''
  end

  def dameRegionesNombresBibliografia(especie)
    distribuciones=nombresComunes=tipoDistribuciones=''
    distribucion={}
    tipoDist=[]
    biblioCont=1

    especie.especies_regiones.each do |e|
      tipoDist << e.tipo_distribucion.descripcion if e.tipo_distribucion_id.present?

      if e.tipo_distribucion_id.present?
        tipo_reg=e.region.tipo_region
        niveles="#{tipo_reg.nivel1}#{tipo_reg.nivel2}#{tipo_reg.nivel3}"
        distribucion[niveles]=[] if distribucion[niveles].nil?

        case niveles
          when '100'
            distribucion[niveles].push('<b>En todo el territorio nacional</b>')
          when '110'
            distribucion[niveles].push('<b>Estatal</b>') if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '111'
            distribucion[niveles].push('<b>Municipal</b>') if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '200'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '300'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '400'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '500'

            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '510'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
          when '511'
            distribucion[niveles].push("<b>#{tipo_reg.descripcion}</b>") if distribucion[niveles].empty?
            distribucion[niveles].push("<li>#{e.region.nombre_region}</li>")
        end
      end

      e.nombres_regiones.where(:region_id => e.region_id).each do |nombre|
        nomBib="#{nombre.nombre_comun.nombre_comun.humanizar} (#{nombre.nombre_comun.lengua.downcase})"
        nombre.nombres_regiones_bibliografias.where(:region_id => nombre.region_id, :nombre_comun_id => nombre.nombre_comun_id).each do |biblio|
          nomBib+=" #{link_to('Bibliografía', '', :id => "link_dialog_#{biblioCont}", :onClick => 'return muestraBibliografiaNombres(this.id);', :class => 'link_azul', :style => 'font-size:11px;')}
<div id=\"biblio_#{biblioCont}\" title=\"Bibliografía\" class=\"biblio\" style=\"display: none\">#{biblio.bibliografia.cita_completa}</div>"
          biblioCont+=1
        end
        nombresComunes+="<li>#{nomBib}</li>"
      end
    end

    distribucion.each do |k, v|
      titulo=true
      v.each do |reg|
        titulo ? distribuciones+="#{reg}<ul>" : distribuciones+=reg
        titulo=false
      end
      distribuciones+='</ul>'
    end

    tipoDist.uniq.each do |d|
      tipoDistribuciones+= "<li>#{d}</li>"
    end

    {:distribuciones => distribuciones, :nombresComunes => nombresComunes, :tipoDistribuciones => tipoDistribuciones}
  end

  def dameStatus(taxon, opciones)
    estatus_a = []
    taxon.especies_estatus.order('estatus_id ASC').each do |estatus|     # Checa si existe alguna sinonimia
      taxSinonimo = Especie.find(estatus.especie_id2)                    # Suponiendo que no levante un raise

      if opciones[:tab_catalogos]
        if taxon.estatus == 2                                              # Valido
          puts taxSinonimo.nombre_cientifico
          estatus_a << tituloNombreCientifico(taxSinonimo, :title => true)
        elsif taxon.estatus == 1 && taxon.especies_estatus.length == 1      # Sinonimo
          estatus_a << tituloNombreCientifico(taxSinonimo, :link => true)
        else
          estatus_a << '<p><strong>Existe un problema con el estatus del nombre científico de este taxón</strong></p>'
        end
      else   # En esta no los pongo en lista
        if taxon.estatus == 2                                              # Valido
          est = "<li>[#{estatus.estatus.descripcion.downcase}] #{tituloNombreCientifico(taxSinonimo, :title => true)}"
          obs = estatus.observaciones.present? ? "<br> <b>Observaciones: </b> #{estatus.observaciones}</li>" : '</li>'
          estatus_a << "#{est} #{obs}"
        elsif taxon.estatus == 1 && taxon.especies_estatus.length == 1      # Sinonimo
          est = tituloNombreCientifico(taxSinonimo, :link => true)
          obs = estatus.observaciones.present? ? "<br> <b>Observaciones: </b> #{estatus.observaciones}" : ''
          estatus_a << "#{est} #{obs}"
        else
          estatus_a << '<p><strong>Existe un problema con el estatus del nombre científico de este taxón</strong></p>'
        end
      end
    end

    if estatus_a.present?
      if opciones[:tab_catalogos]
        taxon.estatus == 2 ? "<strong>Sinónimos: </strong>#{estatus_a.join(', ')}" : "<strong>Aceptado como: </strong>#{estatus_a.join(', ')}"
      else
        titulo = taxon.estatus == 2 ? '<strong>Sinónimos: </strong>' : '<strong>Aceptado como: </strong>'
        taxon.estatus == 2 ? titulo << "<p><ul>#{estatus_a.join('')}</ul></p>" : "<p>#{titulo}#{estatus_a.join('')}</p>"
      end
    else
      ''
    end
  end

  def dameCaracteristica(taxon)
    conservacion=''
    taxon.especies_catalogos.each do |e|
      edo_conserv = e.catalogo.nom_cites_iucn
      if edo_conserv.present?
        I18n.locale.to_s == 'es-cientifico' ?  conservacion+="<li>#{e.catalogo.descripcion}<span style='font-size:9px;'> (#{edo_conserv})</span></li>" :
            conservacion+="#{e.catalogo.descripcion}<span style='font-size:9px;'> (#{edo_conserv})</span>, "
      end
    end

    if conservacion.present?
      I18n.locale.to_s == 'es-cientifico' ? "<p><strong>Característica del taxón:</strong><ul>#{conservacion}</ul></p>" :
          conservacion[0..-3]
    else
      conservacion
    end
  end

  def dameEspecieBibliografia(taxon)
    biblio=''
    taxon.especies_bibliografias.each do |bib|
      biblio_comp = bib.bibliografia.cita_completa
      biblio+="<li>#{bib.bibliografia.cita_completa}</li>" if biblio_comp.present?
    end
    biblio.present? ? "<b>Bibliografía:</b><ul>#{biblio}</ul>" : biblio
  end

  def dame_taxones_inferiores(taxon)
    hijos=''
    child_ids = taxon.child_ids
    return hijos unless child_ids.present?

    Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.caso_rango_valores('especies.id', child_ids.join(',')).order('nombre_cientifico ASC').each do |subTaxon|
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
end
