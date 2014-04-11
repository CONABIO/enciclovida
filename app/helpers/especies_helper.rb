module EspeciesHelper

  def tituloNombreCientifico(taxon, params={})
    if params[:title]
      "#{taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{Especie::ESTATUSES_SIMBOLO[taxon.estatus]} #{taxon.nombre_cientifico} #{taxon.nombre_autoridad}".html_safe
    elsif params[:context]
      "#{taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{Especie::ESTATUSES_SIMBOLO[taxon.estatus]} #{view_context.link_to(taxon.nombre_cientifico, "/especies/#{taxon.id}")} #{taxon.nombre_autoridad}".html_safe
    elsif params[:link]
      "#{taxon.categoria_taxonomica.nombre_categoria_taxonomica} #{Especie::ESTATUSES_SIMBOLO[taxon.estatus]} #{link_to(taxon.nombre_cientifico, "/especies/#{taxon.id}")} #{taxon.nombre_autoridad}".html_safe
    else
      'Ocurrio un error en el t&iacute;tulo'.html_safe
    end
  end

  def enlacesDelArbol(taxon, conClick=nil)
    nodos="<ul><li id='nodo_#{taxon.id}' class='links_arbol'>#{view_context.link_to('±', '', :id => "link_#{taxon.id}", :class => :sub_link_taxon, :onclick => 'return despliegaOcontrae(this.id);')} #{tituloNombreCientifico(taxon, :context => true)}</li>"
    conClick.present? ? nodos[4..-1] : nodos
  end

  def enlacesDeTaxonomia(taxa, nuevo=false)
    enlaces ||="<table width=\"1000\" id=\"enlaces_taxonomicos\"><tr><td>"

    taxa.ancestor_ids.push(taxa.id).each do |ancestro|
      if (taxa.id).equal?(ancestro)
        if nuevo
          e=Especie.find(ancestro)
          enlaces+="#{link_to(e.nombre, e)} (#{e.categoria_taxonomica.nombre_categoria_taxonomica}) > ?   "
        else
          enlaces+="#{taxa.nombre} (#{taxa.categoria_taxonomica.nombre_categoria_taxonomica}) > "
        end
      else
        e=Especie.find(ancestro)
        enlaces+="#{link_to(e.nombre, e)} (#{e.categoria_taxonomica.nombre_categoria_taxonomica}) > "
      end
    end
    "#{enlaces[0..-3]}</td></tr></table>".html_safe
  end

  def arbolTaxonomico
    arbolCompleto ||="<ul class=\"nodo_mayor\">"
    reino=CategoriaTaxonomica.where(:nivel1 => 1, :nivel2 => 0, :nivel3 => 0, :nivel4 => 0).first
    Especie.where(:categoria_taxonomica_id => reino).each do |t|
      arbolCompleto+=enlacesDelArbol(t)
    end
    arbolCompleto+='</ul>'
  end

  def opcionesListas(listas)
    opciones ||=''
    listas.each do |lista|
      opciones+="<option value='#{lista.id}'>#{view_context.truncate(lista.nombre_lista, :length => 40)} (#{lista.cadena_especies.present? ? lista.cadena_especies.split(',').count : 0 } taxones)</option>"
    end
    opciones
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
    opciones ||=''
    iterador.each do |valor, nombre|
      opciones+="<option value=\"#{valor}\">#{nombre}</option>"
    end
    opciones
  end

  def checkboxTipoDistribucion
    checkBoxes ||=''
    TipoDistribucion.all.order('descripcion ASC').each do |tipoDist|
      checkBoxes+="#{check_box_tag("tipo_distribucion_#{tipoDist.id}", tipoDist.id.to_s, false, :class => :busqueda_atributo_checkbox)} #{tipoDist.descripcion}&nbsp;&nbsp;"
    end
    checkBoxes.html_safe
  end

  def checkboxValidoSinonimo(tipoBusqueda)
    checkBoxes ||=''
    Especie::ESTATUSES.each do |e|
      checkBoxes+="#{check_box_tag("estatus_#{tipoBusqueda}_#{e.first}", e.first, false, :class => :busqueda_atributo_checkbox_estatus)} #{e.last}&nbsp;&nbsp;"
    end
    checkBoxes.html_safe
  end

  def dameRegionesNombresBibliografia(especie)
    regiones ||= ''
    nombresComunes ||= ''
    distribuciones ||= ''

    if especie.especies_regiones.count > 0
      distribArray ||= []
      especie.especies_regiones.each do |e|
        regiones+= "<li>#{e.region.nombre_region}</li>" if !e.region.is_root?

        e.nombres_regiones.where(:region_id => e.region_id).each do |nombre|
          nombresComunes+= "<li>#{nombre.nombre_comun.nombre_comun} (#{nombre.nombre_comun.lengua.downcase})</li>"

          #nombre.nombres_regiones_bibliografias.where(:region_id => nombre.region_id).where(:nombre_comun_id => nombre.nombre_comun_id).each do |biblio|
          #detalles ? region+="<p><b>Bibliografía:</b> #{biblio.bibliografia.autor}</p>" : region+="<p><b>Bibliografía:</b> #{biblio.bibliografia.autor.truncate(25)}</p>"
          #end
        end
        distribArray.push(e.tipo_distribucion.descripcion) if e.tipo_distribucion_id.present?
      end
      if distribArray.present?
        distribArray.uniq.each do |d|
          distribuciones+= "<li>#{d}</li>"
        end
      end
    end
    {:regiones => regiones, :nombresComunes => nombresComunes, :distribuciones => distribuciones}
  end

  def dameEspecieEstatuses(taxon)
    if taxon.especies_estatuses.count > 0
      estatuses ||= ''
      taxon.estatus == 2 ? titulo='<strong>Bas&oacute;nimos, sin&oacute;nimos:</strong>' : titulo='<strong>Aceptado como:</strong>'

      taxon.especies_estatuses.order('estatus_id ASC').each do |estatus|
        taxSinonimo = Especie.find(estatus.especie_id2)
        next if taxSinonimo.nil?

        if taxon.estatus == 2
          estatuses+= "<li>[#{estatus.estatus.descripcion.downcase}] #{tituloNombreCientifico(taxSinonimo)}"
          estatuses+= estatus.observaciones.present? ? "<br> <b>Observaciones: </b> #{estatus.observaciones}</li>" : '</li>'
        elsif taxon.estatus == 1 && taxon.especies_estatuses.count == 1
          estatuses+= tituloNombreCientifico(taxSinonimo)
          estatuses+= "<br> <b>Observaciones: </b> #{estatus.observaciones}" if estatus.observaciones.present?
        else
          return '<p><strong>Existe un problema con el estatus del nombre cient&iacute;fico de este tax&oacute;n</strong></p>'
        end
      end
      taxon.estatus == 2 ? titulo + "<p><ul>#{estatuses}</ul></p>" : titulo + "<p>#{estatuses}</p>"
    else
      ''
    end
  end

  def dameCaracteristica(taxon)
    #conservacion='<p><strong>Caracter&iacute;stica del tax&oacute;n:</strong><ul>'
    conservacion=''
    taxon.especies_catalogos.each do |e|
      conservacion+="<li>#{e.catalogo.descripcion}</li>"
    end
    conservacion.present? ? "<p><ul>#{conservacion}</ul></p>" : conservacion
  end

  def dameDescendientesDirectos(taxon)
    if taxon.child_ids.count > 0
      hijos="<fieldset><legend class='leyenda'>Descendientes directos</legend><div id='hijos'><ul>"
      taxon.child_ids.each do |children|
        subTaxon=Especie.find(children)
        hijos+="<li>#{tituloNombreCientifico(subTaxon, :link => true)}</li>" if subTaxon.present?
      end
      hijos+='</div></fieldset></ul>'
    else
      ''
    end
  end

  def dameListas(listas)
    titulo = "<h3>Widget de #{view_context.link_to(:listas, listas_path)}</h3>Autom&aacute;ticamente borra los taxones repetidos de las listas<br>"
    html = if listas.nil?
             "Debes #{view_context.link_to 'iniciar sesi&oacute;n'.html_safe, inicia_sesion_usuarios_path} para poder ver tus listas."
           elsif listas == 0
             "A&uacute;n no has creado ninguna lista. ¿Quieres #{view_context.link_to 'crear una', new_lista_url}?"
           else
             "<i>Puedes a&ntilde;adir taxones a m&aacute;s de una lista. (tecla Ctrl)</i><br><br>
              #{view_context.select_tag('listas_hidden', opcionesListas(listas).html_safe, :multiple => true, :size => (listas.length if listas.length <= 5 || 5), :style => 'width: 380px;')}"
           end
    titulo + html
  end
end
