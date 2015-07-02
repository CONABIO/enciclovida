module ListasHelper
  def despliegaLista(lista, params={})
    taxones = ''
    columnas = lista.columnas.split(',')
    nombresComunesColumnas = lista.nombres_columnas(true)

    datos = lista.datos(params)
    nombresComunesColumnas unless datos.present?

    # Consulta las columnas que selecciono en la lista
    solo_valores = datos.map{|t| [columnas.map{|c| t.send(c)}]}

    solo_valores.each do |valor|
      taxones << "<li>#{valor.join(' <b>,</b> ')}</li>"
    end

    "#{nombresComunesColumnas}<ol id='despliega_lista'>#{taxones}</ol>".html_safe
  end

  # Checkbox para la creacion o edicion
  def checkboxColumnas(columnas = nil)
    checkBoxes = ''
    contador=0

    checkBoxes << '<p><strong>Columnas generales</strong></p>'
    Lista::COLUMNAS_GENERALES.each do |c|
      checkBoxes << '<br>' if contador%2 == 0 && contador != 0   #para darle un mejor espacio
      if columnas.present?
        checkBoxes << check_box_tag('columnas[]', c, columnas.include?(c)) + " #{t("listas_columnas.generales.#{c}")} "
      else
        checkBoxes << check_box_tag('columnas[]', c, false) + " #{t("listas_columnas.generales.#{c}")} "
      end
      contador+=1
    end

    contador=0

    checkBoxes << '<p><strong>Categorías de riesgo y comercio internacional</strong></p>'
    Lista::COLUMNAS_RIESGO_COMERCIO.each do |c|
      checkBoxes << '<br>' if contador%2 == 0 && contador != 0   #para darle un mejor espacio
      if columnas.present?
        checkBoxes << check_box_tag('columnas[]', c, columnas.include?(c)) + " #{t("listas_columnas.generales.#{c}")} "
      else
        checkBoxes << check_box_tag('columnas[]', c, false) + " #{t("listas_columnas.generales.#{c}")} "
      end
      contador+=1
    end

    contador=0

    checkBoxes << '<p><strong>Categorías a exportar</strong></p>'
    Lista::COLUMNAS_CATEGORIAS.each do |c|
      checkBoxes << '<br>' if contador%2 == 0 && contador != 0   #para darle un mejor espacio
      if columnas.present?
        checkBoxes << check_box_tag('columnas[]', c, columnas.include?(c)) + " #{t("listas_columnas.categorias.#{c}")} "
      else
        checkBoxes << check_box_tag('columnas[]', c, false) + " #{t("listas_columnas.categorias.#{c}")} "
      end
      contador+=1
    end
    checkBoxes.html_safe
  end

  # Listas para agregar taxones
  def dameListas(listas)
    if listas.length > 0
      opciones = ''

      # Se hizo de esta forma ya que es mejor poner el conteo de los taxones en las listas
      listas.each do |lista|
        opciones+= "<option value='#{lista.id}'>#{truncate(lista.nombre_lista, :length => 40)} "
        opciones+= "(#{lista.cadena_especies.present? ? lista.cadena_especies.split(',').count : 0 } taxones)</option>"
      end

      "<br><i>Puedes a&ntilde;adir taxones a más de una lista. (tecla Ctrl)</i><br>
              #{select_tag('listas[]', opciones.html_safe, :multiple => true, :size => (listas.length if listas.length <= 5 || 5), :style => 'width: 380px;')}<br><br>"
    else
      "<br><i>Aún no has creado ninguna lista. ¿Quieres #{link_to 'crear una', new_lista_url}?</i>"
    end
  end
end
