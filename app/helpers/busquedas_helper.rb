module BusquedasHelper

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
      link_to('Listado para Revisión (✓)', peticion, :class => 'btn btn-info', :target => :_blank)
    else
      ''
    end
  end
end
