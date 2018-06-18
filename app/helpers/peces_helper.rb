module PecesHelper
    def tituloNombresPeces(taxon, params={})

      nombre = taxon.nombres_comunes.present? ? taxon.nombres_comunes.split(',').first : ''


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

    def checkboxRecomendacion
      checkBoxes = ''
      s = {'Recomendable' => 'v','Poco recomendable' => 'a','Evita' => 'r', 'Sin datos' => 'sn'}
      s.each do |k,v|
        checkBoxes << "<label>"
        checkBoxes << check_box_tag('semaforo_recomendacion[]', v, false, id: "semaforo_recomendacion_#{k}")
        checkBoxes << "<span title = '#{k}' class = 'btn btn-lg btn-basica btn-zona-#{v} btn-title'>"
        checkBoxes << "<i class = '"
        checkBoxes << case k
                      when 'Recomendable'
                        'glyphicon glyphicon-ok-sign'
                      when 'Poco recomendable'
                        'glyphicon glyphicon-exclamation-sign'
                      when 'Evita'
                        'glyphicon glyphicon-minus-sign'
                      when 'Sin datos'
                        'no-data-ev-icon'
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
