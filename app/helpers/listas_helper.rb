module ListasHelper
  def atributoColumnas(lista)
    select="<select id=\"lista_columnas\" multiple=\"multiple\" name=\"lista[columnas][]\" size=\"#{Lista::ATRIBUTOS_TABLAS.size}\">"
    columnas=lista.columnas.split(',')
    Lista::ATRIBUTOS_TABLAS.each do |atributo, nombre|
      if columnas.present?
        if columnas.include?(atributo)
          select+="<option value=\"#{atributo}\" selected>#{nombre}</option>"
        else
          select+="<option value=\"#{atributo}\">#{nombre}</option>"
        end
      else
        select+="<option value=\"#{atributo}\">#{nombre}</option>"
      end
    end
    select+='</select>'
  end

  def columnas(columnas)
    cabecera = ''
    columnas.each do |col|
      cabecera+= "#{t("listas_columnas.#{col}")}, "
    end
    cabecera[0..-3]
  end

  def despliegaLista(lista)
    taxones = ''
    columnas = lista.columnas.split(',')
    nombresComunesColumnas = columnas(columnas)

    if lista.cadena_especies.present?
      begin
        Especie.find(lista.cadena_especies.split(',')).each do |taxon|
          info = taxon.attributes.values_at(*columnas)
          taxones+= "<li>#{info.join(' <b>,</b> ')}</li>"
        end
      rescue
      end
    end
    "#{nombresComunesColumnas}<ol id='despliega_lista'>#{taxones}</ol>".html_safe
  end

  # Checkbox para la creacion o edicion
  def checkboxColumnas(columnas = nil)
    checkBoxes=''
    contador=0

    Lista::COLUMNAS.each do |c|
      checkBoxes+='<br>' if contador%2 == 0 && contador != 0   #para darle un mejor espacio
      if columnas.present?
        checkBoxes+= check_box_tag('columnas[]', c, columnas.include?(c)) + " #{t("listas_columnas.#{c}")}"
      else
        checkBoxes+= check_box_tag('columnas[]', c, false) + " #{t("listas_columnas.#{c}")}"
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

      "<br><i>Puedes a&ntilde;adir taxones a m&aacute;s de una lista. (tecla Ctrl)</i><br>
              #{select_tag('listas[]', opciones.html_safe, :multiple => true, :size => (listas.length if listas.length <= 5 || 5), :style => 'width: 380px;')}<br><br>"
    else
      "<br><i>A&uacute;n no has creado ninguna lista. ¿Quieres #{link_to 'crear una', new_lista_url}?</i>"
    end
  end
end
