module EspeciesHelper

  def enlacesDeTaxonomia(taxa, nuevo=false)
    enlaces ||="<table width=\"1000\" id=\"enlaces_taxonomicos\"><tr><td>#{link_to('Todas las categorias', especies_path)} (administrador) > "

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
      opciones+="<option value=\"#{lista.id}\">#{truncate(lista.nombre_lista, :length => 40)} (#{lista.cadena_especies.present? ? lista.cadena_especies.split(',').count : 0 } taxones)</option>"
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
    #checkBoxes="#{check_box_tag('tipo_distribucion_0', '0', false, :id => 'tipo_distribucion_0', :class => 'busqueda_atributo_checkbox')}todos&nbsp;&nbsp;"
    checkBoxes ||=''
    TipoDistribucion.all.order('descripcion ASC').each do |tipoDist|
      checkBoxes+="#{check_box_tag("tipo_distribucion_#{tipoDist.id}", tipoDist.id.to_s, false, :id => "tipo_distribucion_#{tipoDist.id}", :class => 'busqueda_atributo_checkbox')}#{tipoDist.descripcion}&nbsp;&nbsp;"
    end
    checkBoxes
  end
end
