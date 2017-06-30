# -*- coding: utf-8 -*-
# Modelo sin tabla, solo para automatizar la validacion de archivos excel
class Validacion < ActiveRecord::Base

  belongs_to :usuario

  # Si alguna columna se llama diferente, es solo cosa de añadir un elemento mas al array correspondiente
  COLUMNAS_OPCIONALES = {reino: ['reino'], division: ['division'], subdivision: ['subdivision'], clase: ['clase'], subclase: ['subclase'],
                         orden: ['orden'], suborden: ['suborden'], infraorden: ['infraorden'], superfamilia: ['superfamilia'],
                         subgenero: ['subgenero'], nombre_autoridad_infraespecie: %w(nombre_autoridad_infraespecie autoridad_infraespecie)}
  COLUMNAS_OBLIGATORIAS = {familia: ['familia'], genero: ['genero'], especie: ['especie'], nombre_autoridad: %w(nombre_autoridad autoridad),
                           infraespecie: ['infraespecie'], categoria_taxonomica: %w(categoria categoria_taxonomica), nombre_cientifico: ['nombre_cientifico']}
  FORMATOS_PERMITIDOS_BATCH = %w(text/csv)

  # Colores de las secciones en la validacion
  RESUMEN = '00BFFF'
  CORRECCIONES = 'FF8C00'
  VALIDACION_INTERNA = '32CD32'
  INFORMACION_ORIG = 'C9C9C9'


  # Valida el taxon cuando solo pasan el nombre cientifico
  def valida_batch(path)
    sleep(30)  # Es necesario el sleep ya que trata de leer el archivo antes de que lo haya escrito en disco
    @hash = []
    lineas = File.open(path).read

    lineas.each_line do |linea|
      info = encuentra_record_por_nombre_cientifico_csv(linea.limpia)
      @hash << asocia_respuesta_csv(info)
    end  # Fin each do lineas

    escribe_excel_csv
    EnviaCorreo.excel(self).deliver
  end

  def encuentra_record_por_nombre_cientifico_csv(linea)
    # Evita que el nombre cientifico este vacio
    if linea.blank?
      return {estatus: false, linea: linea, error: 'El nombre cientifico está vacío'}
    end

    taxon = Especie.where(:nombre_cientifico => linea)

    if taxon.length == 1  # Caso mas sencillo, coincide al 100 y solo es uno
      taxon = asigna_categorias_correspondientes(taxon.first)
      return {taxon: taxon, linea: linea, estatus: true}

    elsif taxon.length > 1  # Encontro el mismo nombre cientifico mas de una vez
      # Mando a imprimir solo el valido
      taxon.each do |t|
        if t.estatus == 2
          tax = asigna_categorias_correspondientes(t)
          return {taxon: tax, linea: linea, estatus: true}
        end
      end

      return busca_recursivamente_csv(taxon, linea)

    else
      # Parte de expresiones regulares a ver si encuentra alguna coincidencia
      nombres = linea.split(' ')

      taxon = if nombres.length == 2  # Especie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} % #{nombres[1]}'")
              elsif nombres.length == 3  # Infraespecie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} % #{nombres[1]} % #{nombres[2]}'")
              elsif nombres.length == 1 # Genero o superior
                Especie.where("nombre_cientifico LIKE '#{nombres[0]}'")
              end

      if taxon.present? && taxon.length == 1  # Caso mas sencillo
        taxon = asigna_categorias_correspondientes(taxon.first)
        return {taxon: taxon, linea: linea, estatus: true}
      elsif taxon.present? && taxon.length > 1
        return busca_recursivamente_csv(taxon, linea)
      else  # Lo buscamos con el fuzzy match y despues con el algoritmo de aproximacion
        ids = FUZZY_NOM_CIEN.find(linea, limit=CONFIG.limit_fuzzy)

        if ids.present?
          taxones = Especie.caso_rango_valores('especies.id', ids.join(','))

          if taxones.empty?
            return {estatus: false, linea: linea, error: 'Sin coincidencias'}
          end

          taxones_con_distancia = []
          taxones.each do |taxon|
            # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
            distancia = Levenshtein.distance(linea.downcase, taxon.nombre_cientifico.limpiar.downcase)

            if distancia == 0  # Es exactamente el mismo taxon
              t = asigna_categorias_correspondientes(taxon)
              return {taxon: t, linea: linea, estatus: true}
            end

            next if distancia > 2  # No cumple con la distancia
            taxones_con_distancia << taxon
          end

          if taxones_con_distancia.empty?
            return {estatus: false, linea: linea, error: 'Sin coincidencias'}
          else
            return busca_recursivamente_csv(taxones_con_distancia, linea)
          end

        else  # No hubo coincidencias con su nombre cientifico
          return {estatus: false, linea: linea, error: 'Sin coincidencias'}
        end
      end

    end  #Fin de las posibles coincidencias
  end

  # Si concidio mas de uno, busca recursivamente arriba de genero (familia) para ver el indicado
  def busca_recursivamente_csv(taxones, linea)
    taxon_coincidente = Especie.none
    nombres = linea.split(' ')

    taxones_coincidentes = taxones.map{|t| asigna_categorias_correspondientes(t)}
    taxones_coincidentes.each do |t|  # Iterare cada taxon que resulto parecido para ver cual es el correcto
      t = asigna_categorias_correspondientes(t)
      next unless t.present?  # Por si regresa nulo

      # Si es la especie lo mando directo a coincidencia
      cat_tax_taxon_cat = I18n.transliterate(t.x_categoria_taxonomica).gsub(' ','_').downcase
      if cat_tax_taxon_cat == 'especie' && nombres.length == 2
        return {taxon: t, estatus: true, linea: linea, info: "Posibles coincidencias: #{taxones_coincidentes.map{|t_c| "#{t_c.x_categoria_taxonomica} #{t_c.nombre_cientifico}"}.join(', ')}"}
      end

      # Si no coincidio con ninguno le dejo el unico
      if taxones.length == 1
        return {taxon: t, estatus: true, linea: linea, info: "Posibles coincidencias: #{taxones_coincidentes.map{|t_c| "#{t_c.x_categoria_taxonomica} #{t_c.nombre_cientifico}"}.join(', ')}"}
      end

      return {estatus: false, linea: linea, error: "Posibles coincidencias: #{taxones_coincidentes.map{|t_c| "#{t_c.x_categoria_taxonomica} #{t_c.nombre_cientifico}"}.join(', ')}"}
    end  #Fin each taxones coincidentes
  end

  # Asocia la respuesta para armar el contenido del excel
  def asocia_respuesta_csv(info = {})
    columna_resumen = Hash.new

    if info[:estatus]
      taxon = info[:taxon]

      if taxon.estatus == 1  # Si es sinonimo, asocia el nombre_cientifico valido
        estatus = taxon.especies_estatus     # Checa si existe alguna sinonimia

        if estatus.length == 1  # Encontro el valido y solo es uno, como se esperaba
          begin  # Por si ya no existe ese taxon, suele pasar!
            taxon_valido = Especie.find(estatus.first.especie_id2)
            t_val = asigna_categorias_correspondientes(taxon_valido)  # Le asociamos los datos
            info[:taxon_valido] = t_val
          rescue
            info[:estatus] = false
            info[:error] = 'No existe el taxón válido en CAT'
          end

        else  # No existe el valido >.>!
          info[:estatus] = false
          info[:error] = 'No existe el taxón válido en CAT'
        end
      end  # End estatus = 1

      columna_resumen['SCAT_Observaciones'] = "Información: #{info[:info]}" if info[:info].present?

    else
      columna_resumen['SCAT_Observaciones'] = "Revisión: #{info[:error]}" if info[:error].present?
    end  # End info estatus

    # Se completa la seccion del excel en respuesta
    {nombre_cientifico: info[:linea]}.merge(validacion_interna(info)).merge(columna_resumen)
  end

  # Escribe los datos del excel con la gema rubyXL
  def escribe_excel_csv
    xlsx = RubyXL::Workbook.new
    sheet = xlsx[0]
    sheet.sheet_name = 'Validacion_CONABIO'
    fila = 1  # Uno para que 0 sea la cabecera

    @hash.each do |h|
      columna = 0  # Desde la columna donde empieza

      h.each do |k,v|

        # Para la cabecera
        sheet.add_cell(0,columna,k) if fila == 1

        # Para los demas datos
        sheet.add_cell(fila,columna,v)
        columna+= 1
      end
      fila+= 1

    end

    # Escribe el excel en cierta ruta
    ruta_excel = Rails.root.join('public','validaciones_excel', usuario_id.to_s)
    FileUtils.mkpath(ruta_excel, :mode => 0755) unless File.exists?(ruta_excel)
    puts "#{ruta_excel.to_s}/#{nombre_archivo}.xlsx"
    xlsx.write("#{ruta_excel.to_s}/#{nombre_archivo}.xlsx")
  end

  ###############################################
  # Parte de la validacion del excel
  ###############################################
  # Escribe los datos del excel con la gema rubyXL
  def escribe_excel(path)
    xlsx = RubyXL::Parser.parse(path)  # El excel con su primera sheet
    sheet = xlsx[0]
    fila = 1  # Empezamos por la cabecera

    @hash.each do |h|
      columna = @sheet.last_column  # Desde la columna donde empieza

      h.each do |seccion,datos|

        datos.each do |campo, dato|
          # Para la cabecera, asigna tambien el color correspondiente, de acuerdo a la seccion
          sheet.add_cell(0,columna,campo).change_fill(eval(seccion.to_s.upcase)) if fila == 1

          # Para los datos abajo de la cabecera
          if dato.class == String
            sheet.add_cell(fila,columna,dato)
          elsif dato.class == Hash  # Es la cabecera
            sheet.add_cell(fila,columna,dato[:valor]).change_fill(dato[:color])
          elsif dato.class == Array  # Es de la validación de conabio y tiene un datos desl usuario original
            sheet.add_cell(fila,columna,dato[0]).change_fill(dato[1])
          end

          columna+= 1
        end

      end

      fila+= 1
    end

    # Escribe el excel en cierta ruta
    ruta_excel = Rails.root.join('public','validaciones_excel', usuario_id.to_s)
    FileUtils.mkpath(ruta_excel, :mode => 0755) unless File.exists?(ruta_excel)
    puts "#{ruta_excel.to_s}/#{nombre_archivo}.xlsx"
    xlsx.write("#{ruta_excel.to_s}/#{nombre_archivo}.xlsx")
  end

  # Busca recursivamente el indicado, y valida hasta algun taxon valido en catalogos
  def busca_recursivamente(taxones, hash)
    puts "\n\nBusca recursivamente en subespecie o mas arriba"
    nombre = hash['nombre_cientifico'].limpiar.downcase

    if taxones.length == 1  # Si es uno, no hay de otra que regrese el resultado
      taxon = taxones.first
      taxon.asigna_categorias_correspondientes
      return {taxon: taxon, hash: hash, estatus: true, obs: "Orig: #{nombre};Enciclo: #{taxon.nombre_cientifico}"}
    end

    min = nil
    opciones = []
    opciones_arriba = []
    taxones.each do |taxon|
      taxones_arriba = []
      taxon.asigna_categorias_correspondientes
      taxon.x_distancia = 0
      # Distancia con el nombre cientifico, debe ser menor a 3, pues que en anteriores pasos se valido esta informacion
      taxon.x_distancia+= Levenshtein.distance(nombre, taxon.nombre_cientifico.limpiar.downcase)

      # Lista las categorias taxomicas arriba del taxon y que empiezan de menor a mayor
      categorias = taxon.ancestors.select('nombre_categoria_taxonomica').categoria_taxonomica_join.map(&:nombre_categoria_taxonomica).reverse
      categorias.each do |categoria|
        categoria = I18n.transliterate(categoria).gsub(' ','_').downcase
        valor = eval("taxon.x_#{categoria}.downcase")
        categoria = 'division' if categoria == 'phylum' && !hash.key(categoria)  # En el excel solo ponene division aunque sean del reino animalia ...

        if hash[categoria].present?
          dist = Levenshtein.distance(hash[categoria].downcase, valor)
          taxon.x_distancia+= dist
          taxones_arriba << taxon.ancestors.where(nombre: valor).first if dist == 0
        end
      end

      # Compara y asigna el taxon y la longitud minima
      if min.nil?
        opciones << taxon
        min = taxon.x_distancia
        opciones_arriba << taxones_arriba if taxones_arriba.any?
      else
        if min == taxon.x_distancia
          opciones << taxon
          opciones_arriba << taxones_arriba if taxones_arriba.any?
        elsif taxon.x_distancia < min
          opciones.clear
          opciones << taxon
          min = taxon.x_distancia
          opciones_arriba.clear
          opciones_arriba << taxones_arriba if taxones_arriba.any?
        end
      end

    end  # End each taxones

    # La distancia coincidio con un solo taxon
    if opciones.count == 1
      # Devuelve el primer taxon con la distancia mas chica
      taxon = opciones.first
      return {taxon: taxon, hash: hash, estatus: true, obs: "Orig: #{nombre};Enciclo: #{taxon.nombre_cientifico}"}
    elsif opciones.count > 1  # Hubo mas de una opcion con el mismo peso, validamos mas arriba entonces
      if opciones_arriba.empty?  # No hubo coincidencias arriba
        return {hash: hash, estatus: false, obs: 'Sin coincidencias'}
      elsif opciones_arriba.count == 1  # Hubo una sola coincidencia arriba
        taxon = opciones_arriba[0][0]
        taxon.asigna_categorias_correspondientes
        return {taxon: taxon, hash: hash, estatus: true, obs: "valido hasta #{taxon.x_categoria_taxonomica}", valido_hasta: true}
      elsif opciones_arriba.count > 1  # Hubo más de una coincidencia arriba
        concidencia = opciones_arriba.inject(:&)

        if concidencia.any?  # Entre las coincidencias hubo por lo menos uno, tomo el primero, el ancestro mas cercano
          taxon = concidencia.first
          taxon.asigna_categorias_correspondientes
          return {taxon: taxon, hash: hash, estatus: true, obs: "valido hasta #{taxon.x_categoria_taxonomica}", valido_hasta: true}
        else  # No hubo una coincidencia en comun, entre ancestros
          return {hash: hash, estatus: false, obs: 'Sin coincidencias'}
        end
      end
    else  # No hubo opciones de coincidencia con el mismo peso
      return {hash: hash, estatus: false, obs: 'Sin coincidencias'}
    end  # End opciones count

  end

  # Encuentra el mas parecido
  def encuentra_record_por_nombre_cientifico(hash = {})
    puts "\n Encuentra record por nombre cientifico: #{hash['nombre_cientifico']}"
    # Evita que el nombre cientifico este vacio
    if hash['nombre_cientifico'].blank?
      return {hash: hash, estatus: false, obs: 'El nombre cientifico está vacío'}
    end

    h = hash
    taxones = Especie.where(nombre_cientifico: hash['nombre_cientifico'].strip)

    if taxones.length == 1  # Caso mas sencillo, coincide al 100 y solo es uno
      puts "\n\nCoincidio busqueda exacta"
      taxon = taxones.first
      taxon.asigna_categorias_correspondientes
      return {taxon: taxon, hash: hash, estatus: true}

    elsif taxones.length > 1  # Encontro el mismo nombre cientifico mas de una vez
      puts "\n\nCoincidio mas de uno directo en la base"
      # Mando a imprimir solo el valido
      taxones.each do |taxon|
        if taxon.estatus == 2
          taxon.asigna_categorias_correspondientes
          return {taxon: taxon, hash: hash, estatus: true}
        end
      end

      return busca_recursivamente(taxones, hash)

    else
      puts "\n\nTratando de encontrar concidencias con la base, separando el nombre"
      # Parte de expresiones regulares a ver si encuentra alguna coincidencia
      nombres = hash['nombre_cientifico'].limpiar.downcase.split(' ')

      taxones = if nombres.length == 2  # Especie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} % #{nombres[1]}'")
              elsif nombres.length == 3  # Infraespecie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} % #{nombres[1]} % #{nombres[2]}'")
              elsif nombres.length == 1 # Genero o superior
                Especie.where("nombre_cientifico LIKE '#{nombres[0]}'")
              end

      if taxones.present? && taxones.length == 1  # Caso mas sencillo
        taxon = taxones.first
        taxon.asigna_categorias_correspondientes
        return {taxon: taxon, hash: hash, estatus: true}
      elsif taxones.present? && taxones.length > 1  # Mas de una coincidencia
        return busca_recursivamente(taxones, hash)
      else  # Lo buscamos con el fuzzy match y despues con el algoritmo levenshtein
        puts "\n\nTratando de encontrar concidencias con el fuzzy match"
        ids = FUZZY_NOM_CIEN.find(hash['nombre_cientifico'].limpia, limit=CONFIG.limit_fuzzy)

        if ids.present?
          taxones = Especie.caso_rango_valores('especies.id', ids.join(','))
          return {hash: h, estatus: false, error: 'Sin coincidencias'} if taxones.empty?
          taxones_con_distancia = []

          taxones.each do |taxon|
            # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
            distancia = Levenshtein.distance(hash['nombre_cientifico'].strip.downcase, taxon.nombre_cientifico.limpiar.downcase)

            if distancia == 0  # Es exactamente el mismo taxon
              taxon.asigna_categorias_correspondientes
              return {taxon: taxon, hash: hash, estatus: true}
            end

            next if distancia > 2  # No cumple con la distancia
            taxones_con_distancia << taxon
          end

          if taxones_con_distancia.empty?
            puts "\n\nSin coincidencia"
            return {hash: h, estatus: false, obs: 'Sin coincidencias'}
          else
            return busca_recursivamente(taxones_con_distancia, hash)
          end

        else  # No hubo coincidencias con su nombre cientifico
          puts "\n\nSin coincidencia"

          return {hash: h, estatus: false, obs: 'Sin coincidencias'}
        end
      end

    end  #Fin de las posibles coincidencias
  end

  def valida_campos(path, asociacion)
    puts "\n Validando campos en 30 seg ..."
    sleep(30)  # Es necesario el sleep ya que trata de leer el archivo antes de que lo haya escrito en disco
    @hash = []
    primera_fila = true

    xlsx = Roo::Excelx.new(path, packed: nil, file_warning: :ignore)
    @sheet = xlsx.sheet(0)  # toma la primera hoja por default

    @sheet.parse(asociacion).each do |hash|
      if primera_fila
        primera_fila = false
        next
      end

      info_primer_caso = encuentra_record_por_nombre_cientifico(hash)
      if info_primer_caso[:estatus]  # Encontro por lo menos un nombre cientifico valido y/o un ancestro valido por medio del nombre
        @hash << asocia_respuesta(info_primer_caso.merge({excel: hash}))
      else # No encontro coincidencia con nombre cientifico, probamos con los ancestros, a tratar de coincidir
        nombre_cientifico_orig = hash['nombre_cientifico']
        categorias = (CategoriaTaxonomica::CATEGORIAS & hash.keys).reverse
        encontro_arriba = false

        categorias.each do |categoria|
          next if encontro_arriba
          next if hash[categoria].blank?
          hash['nombre_cientifico'] = hash[categoria]
          info = encuentra_record_por_nombre_cientifico(hash)

          if info[:estatus]  # Encontro por lo menos un nombre cientifico valido y/o un ancestro valido por medio del nombre
            # Me quedo con las categorias superiores y verifico que se encuentre familia u orden
            asegurar_categoria = %w(familia orden)
            index = categorias.index(categoria)
            sub_cats = categorias[index+1..-1]
            # Me asegura que por lo menos estoy abajo de familia
            categorias_coincidio = sub_cats & asegurar_categoria
            if categorias_coincidio.any?
              categorias_coincidio.each do |c|
                #next if encontro_arriba
                if hash[c].try(:downcase) == eval("info[:taxon].x_#{c.downcase}").try(:downcase)
                  info[:hash]['nombre_cientifico'] = nombre_cientifico_orig
                  info[:obs] = "valido hasta #{info[:taxon].x_categoria_taxonomica}"
                  info[:valido_hasta] = true
                  @hash << asocia_respuesta(info.merge({excel: hash}))
                  encontro_arriba = true
                  break
                end
              end

            end

          end  # end if estatus

        end

        @hash << asocia_respuesta(info_primer_caso.merge({excel: hash})) if !encontro_arriba

      end  # info estatus inicial, con el nombre_cientifico original
    end  # sheet parse

    escribe_excel(path)
    EnviaCorreo.excel(self).deliver
  end

  # Asocia la respuesta para armar el contenido del excel
  def asocia_respuesta(info = {})
    puts "\n\nAsocia la respuesta con el excel"
    if info[:estatus]
      taxon = info[:taxon]

      if taxon.estatus == 1  # Si es sinonimo, asocia el nombre_cientifico valido
        estatus = taxon.especies_estatus     # Checa si existe alguna sinonimia

        if estatus.length == 1  # Encontro el valido y solo es uno, como se esperaba
          begin  # Por si ya no existe ese taxon, suele pasar!
            taxon_valido = Especie.find(estatus.first.especie_id2)
            taxon_valido.asigna_categorias_correspondientes
            # Asigna el taxon valido al taxon original
            info[:taxon] = taxon_valido
            info[:taxon_valido] = true
          rescue
            info[:estatus] = false
            info[:error] = 'Sin coincidencias'
          end

        else  # No existe el valido >.>!
          info[:estatus] = false
          info[:error] = 'Sin coincidencias'
        end
      end  # End estatus = 1
    end  # End info estatus

    # Para saber si no era un sinonimo
    if info[:taxon_valido].present?
      info[:scat_estatus] = 'sinónimo'
    elsif info[:obs].blank?
      info[:scat_estatus] = Especie::ESTATUS_SIGNIFICADO[info[:taxon].estatus]
    end

    # Se completa cada seccion del excel
    resumen_hash = resumen(info)
    correcciones_hash = correcciones(info)
    validacion_interna_hash = validacion_interna(info)

    # Devuelve toda la asociacion unida y en orden
    { resumen: resumen_hash, correcciones: correcciones_hash, validacion_interna: validacion_interna_hash }
  end

  # Parte roja del excel
  def resumen(info = {})
    resumen_hash = {}

    if info[:estatus]
      taxon = info[:taxon]
      hash = info[:hash]

      if info[:scat_estatus].present?
        resumen_hash['SCAT_NombreEstatus'] = info[:scat_estatus]
      else
        resumen_hash['SCAT_NombreEstatus'] = nil
      end

      if info[:obs].present?
        resumen_hash['SCAT_Observaciones'] = info[:obs]
      else
        resumen_hash['SCAT_Observaciones'] = nil
      end

      if info[:valido_hasta].present?
        resumen_hash['SCAT_Correccion_NombreCient'] = nil
      else
        resumen_hash['SCAT_Correccion_NombreCient'] = taxon.nombre_cientifico.downcase == hash['nombre_cientifico'].downcase ? nil : taxon.nombre_cientifico
      end

      resumen_hash['SCAT_NombreCient_valido'] = taxon.nombre_cientifico
      resumen_hash['SCAT_Autoridad_NombreCient_valido'] = taxon.nombre_autoridad

    else  # Asociacion vacia, solo el error
      resumen_hash['SCAT_NombreEstatus'] = nil

      if info[:obs].present?
        resumen_hash['SCAT_Observaciones'] = info[:obs]
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
  def correcciones(info = {})
    puts "\n\nGenerando informacion de correcciones ..."
    correcciones_hash = {}
    hash = info[:hash]
    taxon = info[:taxon]

    # Se iteran con los campos que previamente coincidieron en compruebas_columnas
    hash.each do |campo, valor|
      if info[:estatus]

        if campo == 'infraespecie'  # caso especial para las infrespecies
          cat = I18n.transliterate(taxon.x_categoria_taxonomica).gsub(' ','_').downcase

          if CategoriaTaxonomica::CATEGORIAS_INFRAESPECIES.include?(cat)
            correcciones_hash["SCAT_Correccion#{campo.primera_en_mayuscula}"] = taxon.nombre.downcase == hash[campo].try(:downcase) ? nil : taxon.nombre
          else
            correcciones_hash["SCAT_Correccion#{campo.primera_en_mayuscula}"] = nil
          end

        else
          correcciones_hash["SCAT_Correccion#{campo.primera_en_mayuscula}"] = eval("taxon.x_#{campo}").try(:downcase) == hash[campo].try(:downcase) ? nil : eval("taxon.x_#{campo}")
        end

      else
        correcciones_hash["SCAT_Correccion#{campo.primera_en_mayuscula}"] = nil
      end
    end

    correcciones_hash
  end

  def validacion_interna(info = {})
    validacion_interna_hash = {}

    if info[:estatus]
      taxon = info[:taxon]
      excel = info[:excel]

      validacion_interna_hash['SCAT_Reino_valido'] = taxon.x_reino || [excel['Reino'],INFORMACION_ORIG]

      if taxon.x_phylum.present?
        validacion_interna_hash['SCAT_Phylum/Division_valido'] = taxon.x_phylum || [excel['division'], INFORMACION_ORIG] || [excel['phylum'], INFORMACION_ORIG]
      else
        validacion_interna_hash['SCAT_Phylum/Division_valido'] = taxon.x_division || [excel['division'], INFORMACION_ORIG] || [excel['phylum'], INFORMACION_ORIG]
      end

      validacion_interna_hash['SCAT_Clase_valido'] = taxon.x_clase || [excel['clase'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Subclase_valido'] = taxon.x_subclase || [excel['subclase'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Orden_valido'] = taxon.x_orden || [excel['orden'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Suborden_valido'] = taxon.x_suborden || [excel['suborden'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Infraorden_valido'] = taxon.x_infraorden || [excel['infraorden'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Superfamilia_valido'] = taxon.x_superfamilia || [excel['superfamilia'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Familia_valido'] = taxon.x_familia || [excel['familia'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Genero_valido'] = taxon.x_genero || [excel['genero'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Subgenero_valido'] = taxon.x_subgenero || [excel['subgenero'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_Especie_valido'] = taxon.x_especie || [excel['especie'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_AutorEspecie_valido'] = taxon.x_nombre_autoridad || [excel['nombre_autoridad'], INFORMACION_ORIG]

      # Para la infraespecie
      cat = I18n.transliterate(taxon.x_categoria_taxonomica).gsub(' ','_').downcase
      if CategoriaTaxonomica::CATEGORIAS_INFRAESPECIES.include?(cat)
        validacion_interna_hash['SCAT_Infraespecie_valido'] = taxon.nombre || [excel['infraespecie'], INFORMACION_ORIG]
      else
        validacion_interna_hash['SCAT_Infraespecie_valido'] = [excel['infraespecie'], INFORMACION_ORIG]
      end

      validacion_interna_hash['SCAT_Categoria_valido'] = taxon.x_categoria_taxonomica || [excel['categoria_taxonomica'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_AutorInfraespecie_valido'] = taxon.x_nombre_autoridad_infraespecie || [excel['nombre_autoridad_infraespecie'], INFORMACION_ORIG]
      validacion_interna_hash['SCAT_NombreCient_valido'] = taxon.nombre_cientifico || [excel['nombre_cientifico'], INFORMACION_ORIG]

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

    else  # Asociacion vacia, solo el error
      validacion_interna_hash['SCAT_Reino_valido'] = nil
      validacion_interna_hash['SCAT_Phylum/Division_valido'] = nil
      validacion_interna_hash['SCAT_Clase_valido'] = nil
      validacion_interna_hash['SCAT_Subclase_valido'] = nil
      validacion_interna_hash['SCAT_Orden_valido'] = nil
      validacion_interna_hash['SCAT_Suborden_valido'] = nil
      validacion_interna_hash['SCAT_Infraorden_valido'] = nil
      validacion_interna_hash['SCAT_Superfamilia_valido'] = nil
      validacion_interna_hash['SCAT_Familia_valido'] = nil
      validacion_interna_hash['SCAT_Genero_valido'] = nil
      validacion_interna_hash['SCAT_Subgenero_valido'] = nil
      validacion_interna_hash['SCAT_Especie_valido'] = nil
      validacion_interna_hash['SCAT_Especie_valido'] = nil
      validacion_interna_hash['SCAT_AutorEspecie_valido'] = nil
      validacion_interna_hash['SCAT_Infraespecie_valido'] = nil
      validacion_interna_hash['SCAT_Infraespecie_valido'] = nil
      validacion_interna_hash['SCAT_Categoria_valido'] = nil
      validacion_interna_hash['SCAT_AutorInfraespecie_valido'] = nil
      validacion_interna_hash['SCAT_NombreCient_valido'] = nil
      validacion_interna_hash['SCAT_NOM-059'] = nil
      validacion_interna_hash['SCAT_IUCN'] = nil
      validacion_interna_hash['SCAT_CITES'] = nil
      validacion_interna_hash['SCAT_Distribucion'] = nil
      validacion_interna_hash['SCAT_CatalogoDiccionario'] = nil
      validacion_interna_hash['SCAT_Fuente'] = nil
      validacion_interna_hash['ENCICLOVIDA'] = nil
    end

    validacion_interna_hash
  end
end