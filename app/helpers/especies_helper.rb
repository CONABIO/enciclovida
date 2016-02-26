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
        "<span title=\"#{ic.nombre_icono}\" style=\"color:#{ic.color_icono};\" class=\"btn btn-default btn-xs btn-basica #{ic.icono} btn-title #{clase}\" id_icono=\"#{taxon.id}\"></span>"
      else
        "<i title=\"#{ic.nombre_icono}\" style=\"color:#{ic.color_icono};font-size:#{font_size}px;\" class=\"#{ic.icono}\"></i>"
      end
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

    #if taxon.invasora.present?
    #  dist << image_tag('app/tipo_distribuciones/invasora.png', title: 'Invasora')
    #end

    dist.any? ? dist.uniq.join(' - ') : ''
  end

  def dameRegionesNombresBibliografia(especie)
    distribuciones = ''
    nombresComunes=  ''
    tipoDistribuciones = ''
    distribucion = {}
    tipoDist = []
    nombres_comunes_unicos = []
    biblioCont = 1

    especie.especies_regiones.each do |e|
      tipoDist << e.tipo_distribucion.descripcion if e.tipo_distribucion_id.present?

        tipo_reg = e.region.tipo_region
        niveles = "#{tipo_reg.nivel1}#{tipo_reg.nivel2}#{tipo_reg.nivel3}"
        distribucion[niveles] = [] if distribucion[niveles].nil?

      # Separa por niveles la distribucion
        case niveles
          when '100'
            distribucion[niveles].push('<b>Presente en México</b>')
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

      # Parte de los nombres comunes con la bibliografia
      e.nombres_regiones.where(:region_id => e.region_id).each do |nombre|
        # Si ya estaba ese nombre comun, me lo salto
        next if nombres_comunes_unicos.include?("#{nombre.nombre_comun.nombre_comun.humanizar}-#{nombre.nombre_comun.lengua.downcase}")
        nombres_comunes_unicos << "#{nombre.nombre_comun.nombre_comun.humanizar}-#{nombre.nombre_comun.lengua.downcase}"

        nomBib = "#{nombre.nombre_comun.nombre_comun.humanizar} (#{nombre.nombre_comun.lengua.downcase})"
        nombre.nombres_regiones_bibliografias.where(:region_id => nombre.region_id, :nombre_comun_id => nombre.nombre_comun_id).each do |biblio|
          nomBib+=" #{link_to('Bibliografía', '', :id => "link_dialog_#{biblioCont}", :onClick => 'return muestraBibliografiaNombres(this.id);', :class => 'link_azul', :style => 'font-size:11px;')}
<div id=\"biblio_#{biblioCont}\" title=\"Bibliografía\" class=\"biblio\" style=\"display: none\">#{biblio.bibliografia.cita_completa}</div>"
          biblioCont+=1
        end
        nombresComunes+="<li>#{nomBib}</li>"
      end
    end

    distribucion.each do |k, v|
      # Quita el titulo del territorio nacional si tambien esta en un estado en particular
      next if distribucion.count > 1 && k == '100'

      titulo = true
      v.each do |reg|
        titulo ? distribuciones+= "#{reg}<ul>" : distribuciones+= reg
        titulo = false
      end
      distribuciones+= '</ul>'
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
    catalogos = ''
    comercio_int = ''
    ambiente = []
    prioritaria = []
    cat_riesgo = Hash.new

    taxon.especies_catalogos.each do |e|
      cat = e.catalogo
      edo_conserv_nombre = cat.nom_cites_iucn
      ambiente_nombre = cat.ambiente

      if edo_conserv_nombre.present?
        if opciones[:tab_catalogos]
          catalogos << "<li>#{cat.descripcion}<small> (#{edo_conserv_nombre})</small></li>"
        else # Para ordenar las categorias de riesgo y comercio

          if cat.nivel1 == 4 && cat.nivel2 == 1 && cat.nivel3 > 0  # NOM
            cat_riesgo[:a] = "#{image_tag('app/categorias_riesgo/' << t("cat_riesgo.#{cat.descripcion.parameterize}.icono"), title: t("cat_riesgo.#{cat.descripcion.parameterize}.nombre"))}"
          elsif cat.nivel1 == 4 && cat.nivel2 == 2 && cat.nivel3 > 0  # IUCN
            cat_riesgo[:b] = "#{image_tag('app/categorias_riesgo/' << t("cat_riesgo.#{cat.descripcion.parameterize}.icono"), title: t("cat_riesgo.#{cat.descripcion.parameterize}.nombre"))}"
          elsif cat.nivel1 == 4 && cat.nivel2 == 3 && cat.nivel3 > 0  # CITES
            comercio_int << "#{image_tag('app/categorias_riesgo/' << t("cat_riesgo.#{cat.descripcion.parameterize}.icono"), title: t("cat_riesgo.#{cat.descripcion.parameterize}.nombre"))}"

          elsif cat.nivel1 == 4 && cat.nivel2 == 4 && cat.nivel3 > 0  # Prioritarias, DOF, CONABIO
            prioritaria << "#{image_tag('app/prioritarias/' << t("cat_riesgo.#{cat.descripcion.downcase}.icono"), title: t("cat_riesgo.#{cat.descripcion.parameterize}.nombre"))}"
          end
        end
      end

      if ambiente_nombre.present?
        if opciones[:tab_catalogos]
          catalogos << "<li>#{cat.descripcion}<small> (#{ambiente_nombre})</small></li>"
        else
          ambiente << cat.descripcion
        end
      end
    end  #Fin each

    if catalogos.present?
      "<p><strong>Característica del taxón:</strong><ul>#{catalogos}</ul></p>"
    elsif cat_riesgo.any? || comercio_int.present? || ambiente.any?
      res = Hash.new
      res[:cat_riesgo] = cat_riesgo.sort.map{|k,v| v}.join(' ')
      res[:comercio_int] = comercio_int
      res[:ambiente] = ambiente.join(', ')
      res
    else
      catalogos
    end
  end

  def dameCaracteristicaDistribucionAmbienteJS(taxon)
    response = []
    response << taxon.nom_cites_iucn_ambiente_prioritaria

    taxon.especies_regiones.distinct.each do |reg|
      next unless distribucion = reg.tipo_distribucion
      next if distribucion.descripcion == 'Original'  # Quitamos el tipo de dist. original
      response << distribucion.descripcion.parameterize
    end

    # if taxon.invasora.present?
    #   response[:distribucion] << 'idinvasora'
    # end

    response.flatten.uniq
  end

  def ponCaracteristicaDistribucionAmbienteJS(pdf=false)
    response = {}

    #Si solicito un PDF entonces solo pregunto por el ambiente e imprimo texto, no el iconito
    if pdf
      Catalogo.ambiente_todos.each do |amb|
        id = "id#{amb.parameterize}"
        nombre = t("ambiente.#{amb.parameterize}.nombre", :default => '')
        response[:ambiente_pdf] = response[:ambiente].to_a << button_tag(nombre, title: nombre, :class => 'btn btn-default btn-xs btn-img-panel btn-title', :disabled => '', id: id)
      end
    else
      Catalogo.nom_cites_iucn_todos.each do |k, valores|
        valores.each do |edo|
          next if Catalogo::IUCN_QUITAR_EN_FICHA.include?(edo)
          id = "id#{edo.parameterize}"
          icono = t("cat_riesgo.#{edo.parameterize}.icono")
          nombre = t("cat_riesgo.#{edo.parameterize}.nombre")
          response[k] = response[k].to_a << button_tag(image_tag("#{CONFIG.site_url}assets/app/categorias_riesgo/#{icono}", class: 'img-panel', name: "edo_cons_#{edo.parameterize}"), title: nombre, :class => 'btn btn-default btn-xs btn-img-panel btn-title', :disabled => '', id: id)
        end
      end

      TipoDistribucion::DISTRIBUCIONES_SOLO_BASICA.each do |tipoDist|
        id = "id#{tipoDist.parameterize}"
        icono = t("tipo_distribucion.#{tipoDist.parameterize}.icono", :default => '')
        nombre = t("tipo_distribucion.#{tipoDist.parameterize}.nombre", :default => '')
        response[:tipoDistribucion] = response[:tipoDistribucion].to_a << button_tag(image_tag("#{CONFIG.site_url}assets/app/tipo_distribuciones/#{icono}", class: 'img-panel', name: "dist_#{tipoDist}"), title: nombre, :class => 'btn btn-default btn-xs btn-img-panel btn-title', :disabled => '', id: id)
      end

      Catalogo.ambiente_todos.each do |amb|
        id = "id#{amb.parameterize}"
        icono = t("ambiente.#{amb.parameterize}.icono", :default => '')
        nombre = t("ambiente.#{amb.parameterize}.nombre", :default => '')
        response[:ambiente] = response[:ambiente].to_a << button_tag(image_tag("#{CONFIG.site_url}/assets/app/ambientes/#{icono}", class: 'img-panel', name: "amb_#{amb}"), title: nombre, :class => 'btn btn-default btn-xs btn-img-panel btn-title', :disabled => '', id: id)
      end

      Catalogo::NIVELES_PRIORITARIAS.each do |prio|
        id = "id#{prio.parameterize}"
        icono = t("prioritaria.#{prio.parameterize}.icono", :default => '')
        nombre = t("prioritaria.#{prio.parameterize}.nombre", :default => '')
        response[:prioritaria] = response[:prioritaria].to_a << button_tag(image_tag("#{CONFIG.site_url}/assets/app/prioritarias/#{prio.downcase}.png", class: "img-panel", name: "prio_#{prio}"), title: nombre, :class => "btn btn-default btn-xs btn-img-panel btn-title", :disabled => '', id: id)
      end
    end
    response
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
end
