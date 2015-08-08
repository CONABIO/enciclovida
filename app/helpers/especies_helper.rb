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
            "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.nombre_comun} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.nombre_categoria_taxonomica} #{link_to(taxon.nombre_cientifico, especie_path(taxon))} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]})".html_safe
          else
            "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{link_to("#{taxon.nombre_cientifico}", especie_path(taxon))} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
          end
        elsif params[:show]
          "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico} #{taxon.nombre_autoridad} #{Especie::ESTATUS_VALOR[taxon.estatus]}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      end

    else   #vista general
      if taxon.species_or_lower?(taxon.try(:nombre_categoria_taxonomica), true)   # Las especies llevan otro tipo de formato en nombre
        if params[:title]
          taxon.nom_com_prin.present? ? "#{taxon.nom_com_prin} (#{taxon.nombre_cientifico})".html_safe :
              "#{taxon.nombre_cientifico}"
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{ponIcono(taxon, params) if params[:con_icono]} #{link_to(taxon.nombre_comun.humanizar, especie_path(taxon))} (#{ponItalicas(taxon)})".html_safe
          else
            taxon.nom_com_prin.present? ? "#{ponIcono(taxon, params) if params[:con_icono]} #{link_to(taxon.nom_com_prin, especie_path(taxon))} (#{ponItalicas(taxon)})".html_safe :
                "#{ponIcono(taxon, params) if params[:con_icono]} #{ponItalicas(taxon,true)}".html_safe
          end
        elsif params[:show]
          taxon.nom_com_prin.present? ? "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.nom_com_prin} (#{ponItalicas(taxon)})".html_safe :
              "#{ponIcono(taxon, params) if params[:con_icono]} #{ponItalicas(taxon)}".html_safe
        else
          'Ocurrio un error en el título'.html_safe
        end
      else
        if params[:title]
          taxon.nom_com_prin.present? ? "#{taxon.nom_com_prin} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico})".html_safe :
              "#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico}".html_safe
        elsif params[:link]
          if taxon.instance_of? NombreComun   #para cuando busca por nombre comun
            "#{ponIcono(taxon, params) if params[:con_icono]} #{link_to(taxon.nombre_comun.humanizar, especie_path(taxon))} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.nombre_categoria_taxonomica} #{taxon.nombre_cientifico})".html_safe
          else
            taxon.nom_com_prin.present? ? "#{ponIcono(taxon, params) if params[:con_icono]} #{link_to(taxon.nom_com_prin, especie_path(taxon))} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico})".html_safe :
                "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{link_to("#{taxon.nombre_cientifico}", especie_path(taxon))}".html_safe
          end
        elsif params[:show]
          taxon.nom_com_prin.present? ? "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.nom_com_prin} (#{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico})".html_safe :
              "#{ponIcono(taxon, params) if params[:con_icono]} #{taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{taxon.nombre_cientifico}".html_safe
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
    begin  # Es un record con joins
      ic = taxon if taxon.taxon_icono.present?
    rescue
      ic = taxon.adicional.icono.present? ? taxon.adicional.icono : nil
    end

    font_size = params[:font_size].present? ? params[:font_size] : '35'

    if ic.nil?  # Puede que no tenga icono
      "<i title=\"Sin ícono\" style=\"color:black;font-size:0px;\" class=\"sin_icono\"></i>"
    else
      if params[:con_recuadro]
        clase = Icono::IR[-1] if Icono::IR.include?(ic.taxon_icono)
        clase = Icono::IA[-1] if Icono::IA.include?(ic.taxon_icono)
        clase = Icono::IP[-1] if Icono::IP.include?(ic.taxon_icono)
        "<i title=\"#{ic.nombre_icono}\" style=\"color:#{ic.color_icono};\" class=\"#{ic.icono} busqueda_atributo_radio #{clase}\" id_icono=\"#{taxon.id}\"></i>"
      else
        "<i title=\"#{ic.nombre_icono}\" style=\"color:#{ic.color_icono};font-size:#{font_size}px;\" class=\"#{ic.icono}\"></i>"
      end
    end
  end

  def datos_principales(taxon, opciones={})
    datos = dameNomComunes(taxon)
    datos << dameStatus(taxon, opciones)

    dist = dameDistribucion(taxon)
    if dist.present?
      datos << dameDistribucion(taxon) << ' - '
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
        Especie.datos_basicos.
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

        Especie.datos_basicos.where("ancestry_ascendente_directo LIKE '#{ancestry}%'").caso_status('2').
            caso_sensitivo('nombre_categoria_taxonomica',cat_obl[index_cat]).order(:nombre_cientifico).each do |children|
          nodo+= enlacesDelArbol(children, true)
        end
      end
      nodo

    else # Si es para cuando se despliega la pagina
      if taxon.nil?  # Si es el index
        arbolCompleto = ''
        Especie.datos_basicos.where('nivel1=1 AND nivel2=0 AND nivel3=0 AND nivel4=0').each do |t|
          arbolCompleto << "<ul class=\"nodo_mayor\">" + enlacesDelArbol(t) + '</li></ul></ul>'
        end
        # Pone los reinos en una lista separada cada uno
        arbolCompleto

      else # Si es cualquier otro taxon
        tags = ''
        arbolCompleto = "<ul class=\"nodo_mayor\">"
        contadorNodos = 0

        if I18n.locale.to_s == 'es-cientifico'
          Especie.datos_basicos.select('CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').
              caso_rango_valores('especies.id', taxon.path_ids.join(',')).order('nivel').each do |ancestro|
            arbolCompleto << enlacesDelArbol(ancestro)
            contadorNodos+= 1
          end
        else  # Solo las categorias taxonomicas obligatorias
          Especie.datos_basicos.select('CONCAT(nivel1,nivel2,nivel3,nivel4) as nivel').
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
            #{link_to(image_tag('app/32x32/add_page.png'), new_lista_path)}
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
    if I18n.locale.to_s == 'es-cientifico'
      TipoDistribucion::DISTRIBUCIONES.each do |tipoDist|
        next if TipoDistribucion::QUITAR_DIST.include?(tipoDist)
        checkBoxes << "<label class='checkbox' style='margin: 0px 10px;'>#{check_box_tag('dist[]', t('distribucion.' + tipoDist.gsub(' ', '_')), false, :class => :busqueda_atributo_checkbox)} #{t('distribucion.'+tipoDist.gsub(' ', '_'))}</label>"
      end
    else
      TipoDistribucion::DISTRIBUCIONES_SOLO_BASICA.each do |tipoDist|
        checkBoxes << "<span id='dist_#{tipoDist}_span' class='hidden abcd'>#{t('distribucion.'+tipoDist.gsub(' ', '_'))}</span>"
        checkBoxes << "#{image_tag('app/tipo_distribuciones/' << t("tipo_distribucion.#{tipoDist.parameterize}.icono"), title: t("tipo_distribucion.#{tipoDist.parameterize}.nombre"), class: 'img-circle img-thumbnail busqueda_atributo_imagen', name: "dist_#{tipoDist}")}"
        checkBoxes << "#{check_box_tag('dist[]', t('distribucion.' + tipoDist.gsub(' ', '_')), false, id: "dist_#{tipoDist}", :style => 'display:none')}"
      end
    end
    checkBoxes.html_safe
  end

  def checkboxEstadoConservacion
    checkBoxes=''

    Catalogo.nom_cites_iucn_todos.each do |k, valores|
      checkBoxes << "<u><h6>#{t(k)}</h6></u>"
      valores.each do |edo|
        next if edo == 'Riesgo bajo (LR): Dependiente de conservación (cd)' # Esta no esta definida en IUCN, checar con Diana
        checkBoxes << "<span id='edo_cons_#{t("cat_riesgo.#{edo.parameterize}.nombre")}_span' class='hidden abcd'>#{t("cat_riesgo.#{edo.parameterize}.nombre")}</span>"
        checkBoxes << "#{image_tag('app/categorias_riesgo/' << t("cat_riesgo.#{edo.parameterize}.icono"), title: t("cat_riesgo.#{edo.parameterize}.nombre"), class: 'img-circle img-thumbnail busqueda_atributo_imagen', name: "edo_cons_#{edo.parameterize}")}"
        checkBoxes << "#{check_box_tag('edo_cons[]', edo, false, :style => 'display:none', :id => "edo_cons_#{edo.parameterize}")}"
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

  def checkboxPrioritaria
    checkBoxes = "#{image_tag('app/prioritaria.png', title: 'Prioritarias', class: 'img-circle img-thumbnail busqueda_atributo_imagen', name: 'campo_prioritaria')}"
    checkBoxes << check_box_tag('prioritaria', '1', false, :style => 'display:none', :id => 'campo_prioritaria')
  end

  def dameNomComunes(taxon)
    nombres_comunes = ''
    if I18n.locale.to_s == 'es-cientifico'
      nombres = taxon.nombres_comunes.map {|nc| {nc.lengua => nc.nombre_comun.humanizar}}.uniq
    else
      nombres = taxon.nombres_comunes.where("nombre_comun != '#{taxon.nom_com_prin(false).limpia_sql}'").map {|nc| {nc.lengua => nc.nombre_comun.humanizar}}.uniq
    end

    # Agrupa los nombres por su lengua
    agrupa_nombres = nombres.reduce({}) {|h, pairs| pairs.each {|k, v| (h[k] ||= []) << v}; h}
    keys = agrupa_nombres.keys.sort
    keys.each do |k|
      nombres_comunes << "#{agrupa_nombres[k].join(', ')} <small>(#{k})</small> / "
    end
    nombres_comunes.present? ? "<p><strong>Nombres comunes: </strong>#{nombres_comunes[0..-3]}</p>" : nombres_comunes
  end

  def dameDistribucion(taxon)
    dist = []

    taxon.especies_regiones.distinct.each do |reg|
      next unless distribucion = reg.tipo_distribucion
      next if distribucion.descripcion == 'Original'  # Quitamos el tipo de dist. original
      icono = t("tipo_distribucion.#{distribucion.descripcion.parameterize}.icono", :default => '')
      nombre = t("tipo_distribucion.#{distribucion.descripcion.parameterize}.nombre")
      dist << (icono.present? ? image_tag('app/tipo_distribuciones/' << icono, title: nombre) : nombre)
    end

    if taxon.invasora.present?
      dist << image_tag('app/tipo_distribuciones/invasora.png', title: 'Invasora')
    end

    dist.any? ? dist.uniq.join(' - ') : ''
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

  def dameStatus(taxon, opciones={})
    estatus_a = []
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
          puts taxSinonimo.nombre_cientifico
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
  end

  def dameCaracteristica(taxon, opciones={})
    conservacion = ''
    comercio_int = ''
    ambiente = []
    cat_riesgo = Hash.new

    taxon.especies_catalogos.each do |e|
      cat = e.catalogo
      edo_conserv_nombre = cat.nom_cites_iucn
      ambiente_nombre = cat.ambiente

      if edo_conserv_nombre.present?
        if opciones[:tab_catalogos]
          conservacion << "<li>#{cat.descripcion}<small> (#{edo_conserv_nombre})</small></li>"
        else # Para ordenar las categorias de riesgo y comercio
          if cat.nivel1 ==4 && cat.nivel2 == 1 && cat.nivel3 > 0  # NOM
            cat_riesgo[:a] = "NOM 059: #{image_tag('app/categorias_riesgo/' << t("cat_riesgo.#{cat.descripcion.parameterize}.icono"), title: t("cat_riesgo.#{cat.descripcion.parameterize}.nombre"))}"
          elsif cat.nivel1 ==4 && cat.nivel2 == 2 && cat.nivel3 > 0  # IUCN
            cat_riesgo[:b] = "IUCN: #{image_tag('app/categorias_riesgo/' << t("cat_riesgo.#{cat.descripcion.parameterize}.icono"), title: t("cat_riesgo.#{cat.descripcion.parameterize}.nombre"))}"
          elsif cat.nivel1 ==4 && cat.nivel2 == 3 && cat.nivel3 > 0  # CITES
            comercio_int << "CITES: #{image_tag('app/categorias_riesgo/' << t("cat_riesgo.#{cat.descripcion.parameterize}.icono"), title: t("cat_riesgo.#{cat.descripcion.parameterize}.nombre"))}"
          end
        end
      end

      if ambiente_nombre.present?
        if opciones[:tab_catalogos]
          conservacion << "<li>#{cat.descripcion}<small> (#{ambiente_nombre})</small></li>"
        else
          ambiente << cat.descripcion
        end
      end
    end  #Fin each

    if conservacion.present?
      "<p><strong>Característica del taxón:</strong><ul>#{conservacion}</ul></p>"
    elsif cat_riesgo.any? || comercio_int.present? || ambiente.any?
      res = Hash.new
      res[:cat_riesgo] = cat_riesgo.sort.map{|k,v| v}.join(' ')
      res[:comercio_int] = comercio_int
      res[:ambiente] = ambiente.join(', ')
      res
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

  def radioGruposIconicos
    radios = ''
    columnas = 1
    es_reino = " busqueda_atributo_radio_reino"
    Especie.datos_basicos.
        caso_rango_valores('nombre_cientifico', "'#{Icono.all.map(&:taxon_icono).join("','")}'").
        order('ancestry_ascendente_directo, especies.id').each do |taxon|  # Para tener los grupos ordenados

      # Para dejar el espacio despues de los reinos
      if columnas == 6
        radios << '<br>'
        columnas = 7
        es_reino=""
      end

      radios << radio_button_tag(:id_nom_cientifico, taxon.id, false, :style => 'display: none;')
      radios << ponIcono(taxon, con_recuadro: true)
      radios << '<br>' if columnas%6 == 0
      columnas+=1
    end
    "<div style='text-align: center;'>#{radios}</div>"
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
