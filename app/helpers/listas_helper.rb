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

  def self.nombreComunAtributos(lista)
    columnas ||=''
    lista.columnas.split(',').each do |col|
      Lista::ATRIBUTOS_TABLAS.each do |columna, nombre|
        if col.eql?(columna)
          columnas+="#{nombre}, "
        end
      end
    end
    columnas[0..-3]
  end
end
