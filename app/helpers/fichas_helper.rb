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

  def select_multiple_de_catalogos(modelo, association, label_method, value_method)

    modelo.association association,
        label_method: label_method,
        value_method: value_method,
        :as => :select,
        input_html: {
            class: 'form-control selectpicker',
            multiple: true,
            'data-live-search': 'true',
            'title': t('general.seleccionar_opciones'),
            'data-selected-text-format': 'count > 3'
        }

  end


  # Regresar un multiple select de nivel uno
  def select_multiple_nivel_1(modelo, association, pregunta, label)

    num_pregunta = Fichas::Caracteristicasespecie::OPCIONES[pregunta]

    modelo.association association,
        label_method: :descn1,
        value_method: :idopcion,
        collection: Fichas::Cat_Preguntas.where(idpregunta: num_pregunta),
        label: label,
        :as => :select,
        input_html: {
        class: 'form-control selectpicker',
        multiple: true,
        'data-live-search': 'true',
        'title': t('general.seleccionar_opciones'),
        }
  end

  # Regresar un multiple select de nivel uno pero con descripción de la opción con un '->'
  def select_multiple_nivel_1_1(modelo, association, pregunta, label)

    num_pregunta = Fichas::Caracteristicasespecie::OPCIONES[pregunta]

    modelo.association association,
        label_method: ->(obj){
         obj.descn2.blank? ? obj.descn1 : "#{obj.descn1} -> #{obj.descn2}"
        },
        value_method: :idopcion,
        collection: Fichas::Cat_Preguntas.where(idpregunta: num_pregunta),
        label: label,
        :as => :select,
        input_html: {
           class: 'form-control selectpicker',
           multiple: true,
           'data-live-search': 'true',
           'title': t('general.seleccionar_opciones'),
        }
  end

  # Regresar un multiple select de nivel dos (agrupado)
  def select_multiple_nivel_2(modelo, association, pregunta, label)

    collection = Fichas::Cat_Preguntas.where(idpregunta: Fichas::Caracteristicasespecie::OPCIONES[pregunta]).group_by(&:descn1)

    modelo.association association,
        :as => :grouped_select,
        collection: collection,
        :group_method => :last,
        group_label_method: :first,
        label_method: :descn2,
        value_method: :idopcion,
        label: label,
        input_html: {
        :multiple => true,
        class: 'form-control selectpicker',
        'data-live-search': 'true',
        'title': t('general.seleccionar_opciones'),
        'data-selected-text-format': 'count > 3'
    }
  end

  # Regresar un multiple select de nivel tres (agrupado y con paréntesis)
  def select_multiple_nivel_3(modelo, association, pregunta, label)

    collection = Fichas::Cat_Preguntas.where(idpregunta: Fichas::Caracteristicasespecie::OPCIONES[pregunta]).group_by(&:descn1)

    modelo.association association,
          :as => :grouped_select,
          collection: collection,
          :group_method => :last,
          group_label_method: :first,
          label_method: ->(obj){
            obj.descn3.blank? ? obj.descn2 : "#{obj.descn2} (#{obj.descn3})"
          },
          value_method: :idopcion,
          label: label,
          input_html: {
          :multiple => true,
          class: 'form-control selectpicker',
          'data-live-search': 'true',
          'title': t('general.seleccionar_opciones'),
          'data-selected-text-format': 'count > 3'
    }
  end

  def agrega_info_adicional(parametros = { :titulo => "Información adicional", :agregar => "Agregar información adicional" } )

    respuesta = ""

    respuesta << link_to_add_association(
        "<span class='glyphicon glyphicon-plus' aria-hidden='true'></span> #{parametros[:agregar]}".html_safe,
        parametros[:modelo],
        parametros[:association],
        partial: 'fichas/taxa/caracteristicas_especie/observaciones_especie_x',
        render_options: {
            locals: {
                titulo: parametros[:titulo],
                id_pregunta: parametros[:pregunta]
            }
        },
        :class => 'btn btn-info btn-sm',
        role: 'tab',
        "data-toggle" => 'tab',
        "aria-controls" => 'dato_' + parametros[:el_div],
        'data-association-insertion-node' => '#dato_' + parametros[:el_div],
        'data-association-insertion-method' => 'append',
        href: '#dato_' + parametros[:el_div],
        'onclick' => 'reloadTiny()',
        style: 'display: none') if @taxon.new_record? || (!@taxon.new_record? && parametros[:acceso].empty?)

    respuesta.html_safe
  end

end