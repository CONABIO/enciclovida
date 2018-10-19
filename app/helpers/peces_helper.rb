  module PecesHelper

  # Se duplico para utilizarla solo en los resultados, ya que rata de hacer el join con adicionales para cada uno de los peces #facepalm!! >.>! ¬.¬
  def tituloNombreCientificoPeces(taxon, params={})
    nombre = taxon.nombre_comun_principal.try(:capitalize)

    if params[:title]
      nombre.present? ? "#{nombre} (#{taxon.nombre_cientifico})".html_safe : taxon.nombre_cientifico
    elsif params[:link]
      nombre.present? ? "<h5>#{nombre}</h5><h5>#{link_to(ponItalicas(taxon).html_safe, especie_path(taxon))}</h5>" : "<h5>#{ponItalicas(taxon,true)}</h5>"
    elsif params[:show]
      nombre.present? ? "#{nombre} (#{ponItalicas(taxon)})".html_safe : ponItalicas(taxon).html_safe
    else
      'Ocurrio un error en el nombre'.html_safe
    end
  end

  def checkboxGruposIconicos
    checkBoxes = ''
    grupos = params[:grupos_iconicos] || []

    @grupos.each do |taxon|  # Para tener los grupos ordenados
      checkBoxes << "<label>"
      checkBoxes << check_box_tag('grupos_iconicos[]', taxon.id, grupos.include?(taxon.id.to_s), id: "grupos_iconicos_#{taxon.id}")
      checkBoxes << "<span title = '#{taxon.nombre_comun_principal}' class = 'btn btn-xs btn-basica btn-title #{taxon.nombre_cientifico.parameterize}-ev-icon'>"
      checkBoxes << "</span>"
      checkBoxes << "</label>"
    end

    checkBoxes.html_safe
  end

  def checkboxSemaforo
    checkBoxes = ''
    s = {:v => ['Recomendable','semaforo-recomendable'], :a => ['Poco recomendable','semaforo-moderado'], :r => ['Evita','semaforo-evita'], :star => ['Algunas pesquerías hacen esfuerzos para ser sustentables','certificacion'], :sn => ['Especies sin datos','semaforo-no-datos']}
    seleccionados = params[:semaforo_recomendacion] || []

    s.each do |k,v|
      checkBoxes << "<label>"
      checkBoxes << check_box_tag('semaforo_recomendacion[]', k, seleccionados.include?(k.to_s), id: "semaforo_recomendacion_#{v[0].parameterize}")
      checkBoxes << "<span title = '#{v[0]}' class = 'btn btn-basica btn-zona-#{k} btn-title'>"
      checkBoxes << "<i class = '#{v[1]}-ev-icon'></i>"
      checkBoxes << "</span>"

      checkBoxes << "</label>"
    end

    checkBoxes.html_safe
  end

  def checkboxCriteriosPeces(cat, ico=false, titulo=false)
    checkBoxes= titulo ? "<h5><strong>#{titulo}</strong></h5>" : ""

    cat.each do |k, valores|
      filtros = params[k] || []

      valores.each do |edo, id|
        checkBoxes << "<label>"
        checkBoxes << check_box_tag("#{k}[]", id, filtros.include?(id.to_s), :id => "#{k}_#{edo.parameterize}")
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
    lista = ''
    lista << "<ul><li>"
    @zonas[0..2].each_with_index do |z, i|
      lista << "<span class='btn-zona btn-zona-#{pez.valor_zonas[i]}'><i class = '#{valorAIcono(pez.valor_zonas[i])}-ev-icon'></i> - #{z[0]}</span>"
    end
    lista << '</li><li>'
    @zonas[3..5].each_with_index do |z, i|
      lista << "<span class='btn-zona btn-zona-#{pez.valor_zonas[i]}'><i class = '#{valorAIcono(pez.valor_zonas[i])}-ev-icon'></i> - #{z[0]}</span>"
    end
    lista << '</li></ul>'
  end

  def valorAColor valor
    color = case valor
            when -10..4 then "v"
            when 5..19 then "a"
            else "r"
            end
    color
  end

  def valorAIcono valor
    clase = case valor
            when "v" then "semaforo-recomendable"
            when "a" then "semaforo-moderado"
            else "semaforo-evita"
            end
    clase
  end

end
