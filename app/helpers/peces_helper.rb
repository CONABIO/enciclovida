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

    def checkboxSemaforo
      checkBoxes = ''
      #s = {'Recomendable' => 'v','Poco recomendable' => 'a','Evita' => 'r','No se distribuye' => 'n','Sin datos' => 's'}
      s = {'Recomendable' => 'v','Poco recomendable' => 'a','Evita' => 'r'}
      s.each do |k,v|
        checkBoxes << "<label>"
        checkBoxes << check_box_tag('semaforo', v, false, id: "semaforo_#{v}")
        checkBoxes << "<span title = '#{k}' class = 'btn btn-lg btn-basica btn-title'>"
        checkBoxes << "<i class = 'glyphicon glyphicon-"
        checkBoxes << case v
                      when 'v'
                        'ok-sign'
                      when 'a'
                        'exclamation-sign'
                      when 'r'
                        'minus-sign'
                      when 'n'
                        'eye-close'
                      when  's'
                        'question-sign'
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
