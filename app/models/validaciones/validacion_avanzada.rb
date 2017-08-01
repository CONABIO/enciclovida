class ValidacionAvanzada < Validacion

# Asocia la respuesta para armar el contenido del excel
  def asocia_respuesta
    puts "\n\nAsocia la respuesta con el excel"
    taxon_estatus if validacion[:estatus]

    # Se completa cada seccion del excel
    resumen_resp = resumen
    correcciones_resp = correcciones
    validacion_interna_resp = validacion_interna

    # Devuelve toda la asociacion unidas y en orden
    { resumen: resumen_resp, correcciones: correcciones_resp, validacion_interna: validacion_interna_resp }
  end

  # Parte roja del excel
  def resumen
    resumen_hash = {}

    if validacion[:estatus]
      taxon = validacion[:taxon]

      if validacion[:scat_estatus].present?
        resumen_hash['SCAT_NombreEstatus'] = validacion[:scat_estatus]
      else
        resumen_hash['SCAT_NombreEstatus'] = nil
      end

      if validacion[:obs].present?
        resumen_hash['SCAT_Observaciones'] = validacion[:obs]
      else
        resumen_hash['SCAT_Observaciones'] = nil
      end

      if validacion[:valido_hasta].present?
        resumen_hash['SCAT_Correccion_NombreCient'] = nil
      else
        resumen_hash['SCAT_Correccion_NombreCient'] = taxon.nombre_cientifico.downcase == fila['nombre_cientifico'].downcase ? nil : taxon.nombre_cientifico
      end

      resumen_hash['SCAT_NombreCient_valido'] = taxon.nombre_cientifico
      resumen_hash['SCAT_Autoridad_NombreCient_valido'] = taxon.nombre_autoridad

    else  # Asociacion vacia, solo el error
      resumen_hash['SCAT_NombreEstatus'] = nil

      if validacion[:obs].present?
        resumen_hash['SCAT_Observaciones'] = validacion[:obs]
      else
        resumen_hash['SCAT_Observaciones'] = nil
      end

      resumen_hash['SCAT_Correccion_NombreCient'] = nil
      resumen_hash['SCAT_NombreCient_valido'] = nil
      resumen_hash['SCAT_Autoridad_NombreCient_valido'] = nil
    end

    resumen_hash
  end

  # Parte azul del excel
  def correcciones
    puts "\n\nGenerando informacion de correcciones ..."
    correcciones_hash = {}
    taxon = validacion[:taxon]

    # Se iteran con los campos que previamente coincidieron en compruebas_columnas
    fila.each do |campo, valor|
      if validacion[:estatus]

        if campo == 'infraespecie'  # caso especial para las infrespecies
          cat = I18n.transliterate(taxon.x_categoria_taxonomica).gsub(' ','_').downcase

          if CategoriaTaxonomica::CATEGORIAS_INFRAESPECIES.include?(cat)
            correcciones_hash["SCAT_Correccion#{campo.capitalize}"] = taxon.nombre.downcase == fila[campo].try(:downcase) ? nil : taxon.nombre
          else
            correcciones_hash["SCAT_Correccion#{campo.capitalize}"] = nil
          end

        else
          correcciones_hash["SCAT_Correccion#{campo.capitalize}"] = eval("taxon.x_#{campo}").try(:downcase) == fila[campo].try(:downcase) ? nil : eval("taxon.x_#{campo}")
        end

      else
        correcciones_hash["SCAT_Correccion#{campo.capitalize}"] = nil
      end
    end

    correcciones_hash
  end
end