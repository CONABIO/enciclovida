module PecesHelper

  def checkboxGruposIconicos
    checkBoxes = ''

    @grupos.each do |taxon|  # Para tener los grupos ordenados
      checkBoxes << "<label>"
      checkBoxes << check_box_tag('grupos_iconicos[]', taxon.id, false, id: "grupos_iconicos_#{taxon.id}")
      checkBoxes << "<span title = '#{taxon.nombre_comun_principal}' class = 'btn btn-xs btn-basica btn-title #{taxon.nombre_cientifico.parameterize}-ev-icon'>"
      checkBoxes << "</span>"
      checkBoxes << "</label>"
    end

    checkBoxes.html_safe
  end

  def checkboxRecomendacion
    checkBoxes = ''
    s = {:v => ['Recomendable','glyphicon glyphicon-ok-sign'], :a => ['Poco recomendable','glyphicon glyphicon-exclamation-sign'], :r => ['Evita','glyphicon glyphicon-minus-sign'], :star => ['Algunas pesquerías hacen esfuerzos para ser sustentables','glyphicon glyphicon-star'], :sn => ['Especies sin datos','no-data-ev-icon']}
    s.each do |k,v|
      checkBoxes << "<small><b>#{v[0]}:</b></small>" if k == :star || k == :sn
      checkBoxes << "<label>"
      checkBoxes << check_box_tag('semaforo_recomendacion[]', k, false, id: "semaforo_recomendacion_#{v[0].parameterize}")
      checkBoxes << "<span title = '#{v[0]}' class = 'btn btn-lg btn-basica btn-zona-#{k} btn-title'>"
      checkBoxes << "<i class = '#{v[1]}'></i>"
      checkBoxes << "</span>"
      checkBoxes << "</label>"
      #checkBoxes << "<br>" if k == :r
    end

    checkBoxes.html_safe
  end

  def checkboxCriteriosPeces(cat, ico=false, titulo=false)
    checkBoxes= titulo ? "<h5><strong>#{titulo}</strong></h5>" : ""

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

  # Muestra los criterios con el orden indicado
  def muestraCriterios

  end

  def valorAColor valor
    color = case valor
            when -10..4 then "v"
            when 5..19 then "a"
            else "r"
            end
    "btn-zona-#{color}"
  end

end
