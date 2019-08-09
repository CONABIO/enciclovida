module FichasHelper

  def dameCategoriasDeRiesgo
    html = ''

    def iteraCategorias(legislacion)
      html = "<p><strong>#{legislacion.nombreLegislacion}:</strong> #{legislacion.estatusLegalProteccion}</p>"
      html << "<p>Anotacion: #{legislacion.infoAdicional.a_HTML}</p>" if legislacion.infoAdicional.present?
      html
    end

    return html unless @ficha[:legislaciones].any?
    html << '<h4 class="text-center text-primary">Categorías de riesgo nacional/internacional</h4>'

    @ficha[:legislaciones].each do |legislacion|
      html << iteraCategorias(legislacion)
    end

    html.html_safe
  end

  # Regresar un multiple select
  def select_multiple_nivel_1(modelo, association, pregunta)

    modelo.association association,
        label_method: :descn1,
        value_method: :idopcion,
        collection: Fichas::Cat_Preguntas.where(idpregunta: pregunta),
        :as => :select,
        input_html: {
        class: 'form-control selectpicker',
        multiple: true,
        'data-live-search': 'true',
        'title': t('general.seleccionar_opciones'),
        }
  end

  def agrega_info_adicional(modelo, association, agregar, titulo, el_div, pregunta)

    respuesta = link_to_add_association(
                  "<span class='glyphicon glyphicon-plus' aria-hidden='true'></span> #{agregar}".html_safe,
                  modelo,
                  association,
                  partial: 'fichas/taxa/caracteristicas_especie/observaciones_especie_x',
                  render_options: {
                      locals: {
                          titulo: titulo,
                          id_pregunta: pregunta}
                  }, :class => 'btn btn-info btn-sm',
                  role: 'tab', "data-toggle" => 'tab',
                  "aria-controls" => 'dato_' + el_div,
                  'data-association-insertion-node' => '#dato_' + el_div,
                  'data-association-insertion-method' => 'append',
                  href: '#dato_' + el_div
    )

    respuesta << "<div id='#dato_#{el_div}'>".html_safe
    modelo.simple_fields_for association do |info|
      respuesta << (render partial: 'fichas/taxa/caracteristicas_especie/observaciones_especie_x', locals: {f: info, titulo: titulo, id_pregunta: pregunta})
    end
    respuesta <<  "</div><br>.".html_safe

    respuesta
  end

end