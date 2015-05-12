module EspeciesHelper

  def tituloNombreCientifico(taxon, params={})
    # Hace default el icono
    params[:con_icono] = true if params[:con_icono].nil?

    if I18n.locale.to_s == 'es-cientifico'
      if taxon.species_or_lower?(taxon.try(:nombre_categoria_taxonomica), true)   # Las especies llevan otro tipo de formato en nombre
        if params[:title]
          "#{taxon.nombre_cientifico} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}"
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.nombre_comun} (#{ponItalicas(taxon,true)} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe
          else
            "#{ponIcono(taxon, params) if params[:con_icono]} #{ponItalicas(taxon,true)} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          "#{ponIcono(taxon, params) if params[:con_icono]} #{ponItalicas(taxon)} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      else
        if params[:title]
          "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.nombre_comun} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.nombre_categoria_taxonomica} #{link_to(taxon.nombre_cientifico, especy_path(taxon))} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe
          else
            "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{link_to("#{taxon.nombre_cientifico}", especy_path(taxon))} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      end

    else   #vista basica
      if taxon.species_or_lower?(taxon.try(:nombre_categoria_taxonomica), true)   # Las especies llevan otro tipo de formato en nombre
        if params[:title]
          taxon.nombre_comun_principal.present? ? "#{taxon.nombre_comun_principal.humanizar} (#{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
              "#{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]}"
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{ponIcono(taxon, params) if params[:con_icono]} #{link_to(taxon.nombre_comun.humanizar, especy_path(taxon))} (#{ponItalicas(taxon)} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe
          else
            taxon.nombre_comun_principal.present? ? "#{ponIcono(taxon, params) if params[:con_icono]} #{link_to(taxon.nombre_comun_principal.humanizar, especy_path(taxon))} (#{ponItalicas(taxon)} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
                "#{ponIcono(taxon, params) if params[:con_icono]} #{ponItalicas(taxon,true)} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          taxon.nombre_comun_principal.present? ? "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.nombre_comun_principal.humanizar} (#{ponItalicas(taxon)} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
              "#{ponIcono(taxon, params) if params[:con_icono]} #{ponItalicas(taxon)} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      else
        if params[:title]
          taxon.nombre_comun_principal.present? ? "#{taxon.nombre_comun_principal.humanizar} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
              "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{ponIcono(taxon, params) if params[:con_icono]} #{link_to(taxon.nombre_comun.humanizar, especy_path(taxon))} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe
          else
            taxon.nombre_comun_principal.present? ? "#{ponIcono(taxon, params) if params[:con_icono]} #{link_to(taxon.nombre_comun_principal.humanizar, especy_path(taxon))} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
                "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{link_to("#{taxon.nombre_cientifico}", especy_path(taxon))} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          taxon.nombre_comun_principal.present? ? "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.nombre_comun_principal.humanizar} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe :
              "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      end
    end
  end

  # Para separar las italicas del nombre cientifico y la categoria taxonomica
  def ponItalicas(taxon, con_link = false)
    italicas = taxon.nombre_cientifico.gsub('subsp.','</i>subsp.<i>').gsub('var.','</i>var.<i>').gsub('f.','</i>f.<i>').
        gsub('subvar.','</i>subvar.<i>').gsub('subf.','</i>subf.<i>')

    if con_link
      "<a href=\"/especies/#{taxon.id}\"><i>#{italicas}</i></a>"
    else
      "<i>#{italicas}</i>"
    end
  end

  def ponIcono(taxon, params={})
    grupo_iconico = taxon.icono.split('|')
    icono = grupo_iconico[0]
    color = grupo_iconico[1]
    font_size = params[:font_size].present? ? params[:font_size] : '35'

    "<i title=\"#{taxon.nombre_icono}\" style=\"color:#{color};font-size:#{font_size}px;\" class=\"#{icono}\"></i>"
  end

  def datos_principales(taxon, opciones={})
    datos = dameNomComunes(taxon)
    datos << dameStatus(taxon, opciones)

    dist = dameDistribucion(taxon)
    if dist.present?
      datos << '<br>' << dameDistribucion(taxon) << ' - '
    end

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
    nodos << " #{tituloNombreCientifico(taxon, :link => true)}"
    #Deja los nodos abiertos para que esten anidados (si conClick es falso)
    conClick.present? ? "<ul>#{nodos}</li></ul>" : "<ul>#{nodos}"
  end

  def arbolTaxonomico(taxon, accion=false)
    if accion  # Si es para desplegar o contraer
      nodo = ''
      if I18n.locale.to_s == 'es-cientifico'
        Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.
            caso_rango_valores('especies.id', taxon.child_ids.join(',')).order(:nombre_cientifico).each do |children|
          nodo+= enlacesDelArbol(children, true)
        end

      else # Solo las categorias taxonomicas obligatorias
        # Quito las categorias que no pertecene a la estructura del taxon (Division o Phylum)
        cat_obl = if taxon.ancestry_ascendente_directo.include?('1000001') || taxon.id == 1000001
                    CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.map{|c| c if c != 'división'}.compact
                  else
                    CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.map{|c| c if c != 'phylum'}.compact
                  end


        index_cat = cat_obl.index(taxon.categoria_taxonomica.nombre_categoria_taxonomica)
        return '' if index_cat.nil?  # Si no encontro la categoria
        return '' if index_cat == cat_obl.length - 1 # Si es la ultima categoria
        index_cat+= 1

        ancestry = taxon.is_root? ? taxon.id : "#{taxon.ancestry_ascendente_directo}/#{taxon.id}"
        Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.
            where("ancestry_ascendente_directo LIKE '#{ancestry}%'").
            caso_sensitivo('nombre_categoria_taxonomica',cat_obl[index_cat]).order(:nombre_cientifico).each do |children|
          nodo+= enlacesDelArbol(children, true)
        end
      end
      nodo

    else # Si es para cuando se despliega la pagina
      if taxon.nil?  # Si es el index
        arbolCompleto = ''
        Especie.select('especies.*, nombre_categoria_taxonomica').categoria_taxonomica_join.
            where('nivel1=1 AND nivel2=0 AND nivel3=0 AND nivel4=0').each do |t|
          arbolCompleto << "<ul class=\"nodo_mayor\">" + enlacesDelArbol(t) + '</li></ul></ul>'
        end
        # Pone los reinos en una lista separada cada uno
        arbolCompleto

      else # Si es cualquier otro taxon
        tags = ''
        arbolCompleto = "<ul class=\"nodo_mayor\">"
        contadorNodos = 0

        if I18n.locale.to_s == 'es-cientifico'
          Especie.select('especies.*, nombre_categoria_taxonomica, CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').categoria_taxonomica_join.
              caso_rango_valores('especies.id', taxon.path_ids.join(',')).order('nivel').each do |ancestro|
            arbolCompleto << enlacesDelArbol(ancestro)
            contadorNodos+= 1
          end
        else  # Solo las categorias taxonomicas obligatorias
          Especie.select('especies.*, nombre_categoria_taxonomica, CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').categoria_taxonomica_join.
              caso_rango_valores('especies.id', taxon.path_ids.join(',')).
              caso_rango_valores('nombre_categoria_taxonomica', CategoriaTaxonomica::CATEGORIAS_OBLIGATORIAS.map{|c| "'#{c}'"}.join(',')).
              order('nivel').each do |ancestro|
            arbolCompleto << enlacesDelArbol(ancestro)
            contadorNodos+= 1
          end
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

    TipoDistribucion::DISTRIBUCIONES.each do |tipoDist|
      next if TipoDistribucion::QUITAR_DIST.include?(tipoDist)

      if I18n.locale.to_s != 'es-cientifico'
        next if TipoDistribucion::QUITAR_DIST_SOLO_BASICA.include?(tipoDist)
      end
      checkBoxes+="<label class='checkbox' style='margin: 0px 10px;'>#{check_box_tag('dist[]', t('distribucion.'+tipoDist.gsub(' ', '_')), false, :class => :busqueda_atributo_checkbox)} #{t('distribucion.'+tipoDist.gsub(' ', '_'))}</label>"
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
    if I18n.locale.to_s == 'es-cientifico'
      nombres = taxon.nombres_comunes.map {|nc| {nc.lengua => nc.nombre_comun.humanizar}}.uniq
    else
      nombres = taxon.nombres_comunes.where("nombre_comun != '#{taxon.nombre_comun_principal}'").map {|nc| {nc.lengua => nc.nombre_comun.humanizar}}.uniq
    end

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
          est = "<li>#{tituloNombreCientifico(taxSinonimo, :title => true)}"
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
          puts taxSinonimo.nombre_cientifico
          estatus_a << tituloNombreCientifico(taxSinonimo, :title => true)
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
        taxon.estatus == 2 ? "<strong>Sinónimos: </strong>#{estatus_a.map{|estat| estat.gsub('sinónimo','')}.join(', ')}" : "<strong>Aceptado como: </strong>#{estatus_a.join(', ')}"
      end
    else
      ''
    end
  end

  def dameCaracteristica(taxon, opciones={})
    conservacion=''
    taxon.especies_catalogos.each do |e|
      edo_conserv = e.catalogo.nom_cites_iucn
      if edo_conserv.present?
        opciones[:tab_catalogos] ?  conservacion+="<li>#{e.catalogo.descripcion}<span style='font-size:9px;'> (#{edo_conserv})</span></li>" :
            conservacion+="#{e.catalogo.descripcion}<span style='font-size:9px;'> (#{edo_conserv})</span>, "
      end
    end

    if conservacion.present?
      opciones[:tab_catalogos] ? "<p><strong>Característica del taxón:</strong><ul>#{conservacion}</ul></p>" :
          "<p><strong>Categorías de riesgo:</strong><br>#{conservacion[0..-3]}</p>"
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

  def radioGruposIconicos
    radios = ''
    Especie.caso_rango_valores('nombre_cientifico', "'#{Adicional::GRUPOS_ICONICOS.keys.join("','")}'").
        order('ancestry_ascendente_directo, especies.id').each do |taxon|  # Para tener los grupos ordenados
      radios << radio_button_tag(:id_nom_cientifico, taxon.id, false, :class => 'busqueda_atributo_radio')
      radios << ponIcono(taxon)
    end
    "<div>#{radios}</div>"
  end

  def checklist(datos)
    if datos[:totales] > 0
      sin_page_per_page = datos[:request].split('&').map{|attr| attr if !attr.include?('pagina=')}
      peticion = sin_page_per_page.compact.join('&')
      peticion << "&por_pagina=#{datos[:totales]}&checklist=1"
      link_to('Listado para Revisión (✓)', peticion, :class => 'btn btn-info pull-right', :target => :_blank)
    else
      ''
    end
  end
end
