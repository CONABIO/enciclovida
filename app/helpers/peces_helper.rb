module PecesHelper
    def tituloNombreCientificoPeces(taxon, params={})

      nombre = taxon.nombres_comunes.present? ? taxon.nombres_comunes.split(',').first : ''


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

    def checkboxRecomendacion
      checkBoxes = ''
      s = {'Recomendable' => 'v','Poco recomendable' => 'a','Evita' => 'r'}
      s.each do |k,v|
        checkBoxes << "<label>"
        checkBoxes << check_box_tag('semaforo_recomendacion', v, false, id: "semaforo_recomendacion_#{k}")
        checkBoxes << "<span title = '#{k}' class = 'btn btn-lg btn-basica btn-zona-#{v} btn-title'>"
        checkBoxes << "<i class = 'glyphicon glyphicon-"
        checkBoxes << case k
                      when 'Recomendable'
                        'ok-sign'
                      when 'Poco recomendable'
                        'exclamation-sign'
                      when 'Evita'
                        'minus-sign'
                      else
                        'stop'
                      end
        checkBoxes << "'></i>"
        checkBoxes << "</span>"
        checkBoxes << "</label>"
      end
      checkBoxes.html_safe
    end

    def checkboxValorTotal
      checkBoxes = ''
      s = {'Recomendable' => '-5,4','Poco recomendable' => '5,20','Evita' => '20,100'}
      s.each do |k,v|
        checkBoxes << "<label>"
        checkBoxes << check_box_tag('semaforo_vt', v, false, id: "semaforo_vt_#{k}")
        checkBoxes << "<span title = '#{k}' class = 'btn btn-lg btn-basica btn-title'>"
        checkBoxes << "<i class = 'glyphicon glyphicon-"
        checkBoxes << case k
                      when 'Recomendable'
                        'ok-sign'
                      when 'Poco recomendable'
                        'exclamation-sign'
                      when 'Evita'
                        'minus-sign'
                      else
                        'stop'
                      end
        checkBoxes << "'></i>"
        checkBoxes << "</span>"
        checkBoxes << "</label>"
      end
      checkBoxes.html_safe
    end

end
