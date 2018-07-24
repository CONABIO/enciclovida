module PecesHelper

  def tituloNombresPeces(taxon, params={})
    nombre = taxon.nombre_comun_principal.present? ? taxon.nombre_comun_principal : ''

    if params[:title]
      nombre.present? ? "<h4>#{nombre}</h4> <h5>#{taxon.nombre_cientifico}</h5>".html_safe : taxon.nombre_cientifico
    elsif params[:link]
      nombre.present? ? "<h4>#{nombre}</h4><h5>#{link_to(ponItalicas(taxon).html_safe, especie_path(taxon))}</h5>" : "<h5>#{ponItalicas(taxon,true)}</h5>"
    elsif params[:show]
      nombre.present? ? "#{nombre} (#{ponItalicas(taxon)})".html_safe : ponItalicas(taxon).html_safe
    else
      'Ocurrio un error en el nombre'.html_safe
    end
  end

  def checboxEstrella
    checkBox = ''
    checkBox << "<label>"
    checkBox << check_box_tag('con_estrella[]', '1', false, id: 'con_estrella')
    checkBox << "<span title='Especies certificadas' class = 'btn btn-lg btn-basica btn-title con-estrella'>"
    checkBox << "<i class = 'glyphicon glyphicon-star'></i>"
    checkBox << "</span>"
    checkBox << "</label>"
    checkBox.html_safe
  end

  def checkboxRecomendacion
    checkBoxes = ''
    s = {:v => ['Recomendable','glyphicon glyphicon-ok-sign'], :a => ['Poco recomendable','glyphicon glyphicon-exclamation-sign'], :r => ['Evita','glyphicon glyphicon-minus-sign'], :sn => ['Sin datos','no-data-ev-icon']}
    s.each do |k,v|
      checkBoxes << "<label>"
      checkBoxes << check_box_tag('semaforo_recomendacion[]', k, false, id: "semaforo_recomendacion_#{v[0]}")
      checkBoxes << "<span title = '#{v[0]}' class = 'btn btn-lg btn-basica btn-zona-#{k} btn-title'>"
      checkBoxes << "<i class = '#{v[1]}'></i>"
      checkBoxes << "</span>"
      checkBoxes << "</label>"
    end

    checkBoxes.html_safe
  end

  def checkboxCriteriosPeces(cat, ico=false, titulo='')
    checkBoxes="<h5><strong>#{titulo}</strong></h5>"

    cat.each do |k, valores|
      valores.each do |edo, id|
        checkBoxes << "<label>"
        checkBoxes << check_box_tag("#{k}[]", id, false, :id => "#{k}_#{edo.parameterize}")
        checkBoxes << "<span title = '#{edo}' class = '#{k} btn btn-xs btn-basica btn-title #{'btn-default' unless ico}'>"
        checkBoxes << "#{edo}" unless ico
        checkBoxes << "<i class = '#{edo.parameterize}-ev-icon'></i>" if ico
        checkBoxes << "</span>"
        checkBoxes << "</label>"
      end
    end

    checkBoxes.html_safe
  end

  def dibujaZonasPez pez
    @filtros[:zonas]
    lista = '<ul>'<<'<small><b>Zonas: </b></small>'
    @filtros[:zonas].each_with_index do |z, i|
      lista << "<li tooltip-title='#{z[0]}' class='btn-title btn-zona btn-zona-#{pez.valor_zonas[i]}'>#{z[0].split(' ').last}</li>"
    end
    lista << '</ul>'
  end

end
