class ValidacionAvanzada < Validacion

  # Si alguna columna se llama diferente, es solo cosa de añadir un elemento mas al array correspondiente
  COLUMNAS_OPCIONALES = {reino: ['reino'], division: ['division'], subdivision: ['subdivision'], clase: ['clase'], subclase: ['subclase'],
                         orden: ['orden'], suborden: ['suborden'], infraorden: ['infraorden'], superfamilia: ['superfamilia'],
                         subgenero: ['subgenero'], nombre_autoridad_infraespecie: %w(nombre_autoridad_infraespecie autoridad_infraespecie)}
  COLUMNAS_OBLIGATORIAS = {familia: ['familia'], genero: ['genero'], especie: ['especie'], nombre_autoridad: %w(nombre_autoridad autoridad),
                           infraespecie: ['infraespecie'], categoria_taxonomica: %w(categoria categoria_taxonomica), nombre_cientifico: ['nombre_cientifico']}

  def valida_excel
    super

    sheet.parse(cabecera).each_with_index do |f, index|
      next if index == 0
      self.fila = f
      encuentra_por_nombre

      if validacion[:estatus]  # Encontro por lo menos un nombre cientifico valido
        self.excel_validado << asocia_respuesta
      else # No encontro coincidencia con nombre cientifico, probamos con los ancestros, a tratar de coincidir
        # Para salir del programa con el mensaje original
        if validacion[:salir]
          self.excel_validado << asocia_respuesta
          next
        end

        # Las interseccion de categorias validas entre el excel y las permitidas
        categorias = (CategoriaTaxonomica::CATEGORIAS & fila.keys).reverse
        asegurar_categoria = %w(genero familia orden)  # Solo estas categorias se sube a validar
        nombre_cientifico_orig = fila['nombre_cientifico']

        categorias.each do |categoria|
          next unless fila[categoria].present?
          next unless asegurar_categoria.include?(categoria)
          puts "\n Tratando de encontrar mas arriba: #{categoria}"

          # Asigna una categoria mas arriba a nombre cientifico
          fila['nombre_cientifico'] = fila[categoria]
          encuentra_por_nombre

          if validacion[:estatus]  # Encontro por lo menos un nombre cientifico valido y/o un ancestro valido por medio del nombre
            fila['nombre_cientifico'] = nombre_cientifico_orig  # Regresa su nombre cientifico original
            validacion[:obs] = "valido hasta #{validacion[:taxon].x_categoria_taxonomica}"
            validacion[:valido_hasta] = true
            self.excel_validado << asocia_respuesta
            break
          end
        end

        # Por si no hubo ningun valido
        if !validacion[:estatus]
          validacion[:obs] = 'Sin coincidencias'
          self.excel_validado << asocia_respuesta
        end

      end  # info estatus inicial, con el nombre_cientifico original
    end  # sheet parse

    escribe_excel
    EnviaCorreo.excel(self).deliver if Rails.env.production?
  end

# Asocia la respuesta para armar el contenido del excel
  def asocia_respuesta
    puts "\n\nAsocia la respuesta con el excel"
    taxon_estatus if validacion[:estatus]

    # Se completa cada seccion del excel
    resumen = self.resumen
    correcciones = self.correcciones
    validacion_interna = self.validacion_interna

    # Devuelve toda la asociacion unidas y en orden
    { resumen: resumen, correcciones: correcciones, validacion_interna: validacion_interna }
  end

  private

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

# La validacion en comun, no importa si es simple o avanzada
  def validacion_interna
    validacion_interna_hash = {}

    if validacion[:estatus]
      taxon = validacion[:taxon]

      validacion_interna_hash['SCAT_Reino_valido'] = taxon.x_reino || [fila['Reino'],INFORMACION_ORIG]

      if taxon.x_phylum.present?
        validacion_interna_hash['SCAT_Phylum/Division_valido'] = taxon.x_phylum || [fila['division'], INFORMACION_ORIG] || [fila['phylum'], INFORMACION_ORIG]
      else
        validacion_interna_hash['SCAT_Phylum/Division_valido'] = taxon.x_division || [fila['division'], INFORMACION_ORIG] || [fila['phylum'], INFORMACION_ORIG]
      end

      validacion_interna_hash['SCAT_Clase_valido'] = taxon.x_clase || [fila['clase'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Subclase_valido'] = taxon.x_subclase || [fila['subclase'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Orden_valido'] = taxon.x_orden || [fila['orden'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Suborden_valido'] = taxon.x_suborden || [fila['suborden'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Infraorden_valido'] = taxon.x_infraorden || [fila['infraorden'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Superfamilia_valido'] = taxon.x_superfamilia || [fila['superfamilia'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Familia_valido'] = taxon.x_familia || [fila['familia'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Genero_valido'] = taxon.x_genero || [fila['genero'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Subgenero_valido'] = taxon.x_subgenero || [fila['subgenero'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Especie_valido'] = taxon.x_especie || [fila['especie'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_AutorEspecie_valido'] = taxon.x_nombre_autoridad || [fila['nombre_autoridad'], INFORMACION_ORIG]

      # Para la infraespecie
      cat = I18n.transliterate(taxon.x_categoria_taxonomica).gsub(' ','_').downcase
      if CategoriaTaxonomica::CATEGORIAS_INFRAESPECIES.include?(cat)
        validacion_interna_hash['SCAT_Infraespecie_valido'] = taxon.nombre || [fila['infraespecie'], INFORMACION_ORIG]
      else
        validacion_interna_hash['SCAT_Infraespecie_valido'] = [fila['infraespecie'], INFORMACION_ORIG]
      end

      validacion_interna_hash['SCAT_Categoria_valido'] = taxon.x_categoria_taxonomica || [fila['categoria_taxonomica'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_AutorInfraespecie_valido'] = taxon.x_nombre_autoridad_infraespecie || [fila['nombre_autoridad_infraespecie'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_NombreCient_valido'] = taxon.nombre_cientifico || [fila['nombre_cientifico'], INFORMACION_ORIG]

      # Para la NOM
      nom = taxon.estados_conservacion.where('nivel1=4 AND nivel2=1 AND nivel3>0').distinct
      if nom.length == 1
        taxon.x_nom = nom[0].descripcion
        validacion_interna_hash['SCAT_NOM-059'] = taxon.x_nom
      else
        validacion_interna_hash['SCAT_NOM-059'] = nil
      end

      # Para IUCN
      iucn = taxon.estados_conservacion.where('nivel1=4 AND nivel2=2 AND nivel3>0').distinct
      if iucn.length == 1
        taxon.x_iucn = iucn[0].descripcion
        validacion_interna_hash['SCAT_IUCN'] = taxon.x_iucn
      else
        validacion_interna_hash['SCAT_IUCN'] = nil
      end

      cites = taxon.estados_conservacion.where('nivel1=4 AND nivel2=3 AND nivel3>0').distinct
      if cites.length == 1
        taxon.x_cites = cites[0].descripcion
        validacion_interna_hash['SCAT_CITES'] = taxon.x_cites
      else
        validacion_interna_hash['SCAT_CITES'] = nil
      end

      # Para el tipo de distribucion
      tipos_distribuciones = taxon.tipos_distribuciones.map(&:descripcion).uniq

      if tipos_distribuciones.any?
        taxon.x_tipo_distribucion = tipos_distribuciones.join(',')
        validacion_interna_hash['SCAT_Distribucion'] = taxon.x_tipo_distribucion
      else
        validacion_interna_hash['SCAT_Distribucion'] = nil
      end

      validacion_interna_hash['SCAT_CatalogoDiccionario'] = taxon.sis_clas_cat_dicc
      validacion_interna_hash['SCAT_Fuente'] = taxon.fuente
      validacion_interna_hash['ENCICLOVIDA'] = "http://www.enciclovida.mx/especies/#{taxon.id}"
      validacion_interna_hash['SNIB'] = nil

      # Datos del SNIB
      if p = taxon.proveedor
        geodatos = p.geodatos
        if geodatos[:cuales].any? && geodatos[:cuales].include?('geoportal')
          validacion_interna_hash['SNIB'] = geodatos[:geoportal_url]
        end
      end

    else  # Asociacion vacia, solo el error
      validacion_interna_hash['SCAT_Reino_valido'] = [fila['Reino'],INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Phylum/Division_valido'] = [fila['division'], INFORMACION_ORIG] || [fila['phylum'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Clase_valido'] = [fila['clase'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Subclase_valido'] = [fila['subclase'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Orden_valido'] = [fila['orden'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Suborden_valido'] = [fila['suborden'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Infraorden_valido'] = [fila['infraorden'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Superfamilia_valido'] = [fila['superfamilia'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Familia_valido'] = [fila['familia'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Genero_valido'] = [fila['genero'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Subgenero_valido'] = [fila['subgenero'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Especie_valido'] = [fila['especie'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_AutorEspecie_valido'] = [fila['nombre_autoridad'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Infraespecie_valido'] = [fila['infraespecie'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Categoria_valido'] = [fila['categoria_taxonomica'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_AutorInfraespecie_valido'] = [fila['nombre_autoridad_infraespecie'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_NombreCient_valido'] = [fila['nombre_cientifico'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_NOM-059'] = [nil, INFORMACION_ORIG]
      validacion_interna_hash['SCAT_IUCN'] = [nil, INFORMACION_ORIG]
      validacion_interna_hash['SCAT_CITES'] = [nil, INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Distribucion'] = [nil, INFORMACION_ORIG]
      validacion_interna_hash['SCAT_CatalogoDiccionario'] = [nil, INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Fuente'] = [nil, INFORMACION_ORIG]
      validacion_interna_hash['ENCICLOVIDA'] = [nil, INFORMACION_ORIG]
      validacion_interna_hash['SNIB'] = [nil, INFORMACION_ORIG]
    end

    validacion_interna_hash
  end
end