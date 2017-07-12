# -*- coding: utf-8 -*-
# Modelo sin tabla, solo para automatizar la validacion de archivos excel
class Validacion < ActiveRecord::Base

  belongs_to :usuario

  # El excel que subio, la cabecera del excel, la fila en cuestion del excel y la respuesta de alguna consulta, y el excel de respuesta
  attr_accessor :excel, :cabecera, :fila, :validacion, :excel_valido

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

=begin
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
=end

  ###############################################
  # Parte de la validacion del excel
  ###############################################
  # Escribe los datos del excel con la gema rubyXL
  def escribe_excel
    xlsx = RubyXL::Parser.parse(excel)  # El excel con su primera sheet
    sheet = xlsx[0]
    fila = 1  # Empezamos por la cabecera

    excel_valido.each do |h|
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

  # Busca recursivamente el indicado
  def busca_recursivamente
    puts "\n\nBusca recursivamente"
    validacion[:taxones].each do |taxon|
      validacion[:taxon] = taxon
      coincide_familia_orden?

      # estamos seguros que no hay coincidencias, salimos
      return if validacion[:salir]

      if validacion[:estatus]
        validacion[:obs] = "Orig: #{fila['nombre_cientifico']}; Enciclo: #{taxon.nombre_cientifico}"
        return
      end
    end
  end

  def coincide_familia_orden?  # Valida si coincide con la familia o el orden, en este punto ya tengo un taxon candidato
    taxon = validacion[:taxon]
    taxon.asigna_categorias
    validacion[:taxon] = taxon

    # Si no esta puesta la familia en el taxon que coincide, entonces quiere decir que ya subio hasta familia y no es igual, entonces no hubo coincidencias
    if taxon.x_familia.blank?
      validacion[:estatus] = false
      validacion[:obs] = 'Sin coincidencias'
      validacion[:salir] = true
      return
    end

    if fila['familia'].present?  # Si escribio la familia en el excel entonces debe de coincidir
      if fila['familia'].downcase.strip == taxon.x_familia.downcase.strip
        validacion[:estatus] = true
      else
        validacion[:estatus] = false
        validacion[:obs] = "No coincidio la famila - Orig: #{fila['familia']}; Enciclo: #{taxon.x_familia}"
        validacion[:salir] = true
      end
    elsif fila['orden'].present?  # Si escribio el orden
      if fila['orden'].downcase.strip == taxon.x_orden.downcase.strip
        validacion[:estatus] = true
      else
        validacion[:estatus] = false
        validacion[:obs] = "No coincidio el orden - Orig: #{fila['orden']}; Enciclo: #{taxon.x_orden}"
        validacion[:salir] = true
      end
    else  # No tiene ni familia ni orden, entonces lo regreso valido
      validacion[:estatus] = true
    end

    puts "\n\n\nEncontro en familia u orden: #{validacion[:estatus].to_s}"
  end

  # Este metodo se manda a llamar cuando el taxon coincidio ==  validacion[:estatus] = true
  def taxon_estatus
    taxon = validacion[:taxon]

    if taxon.estatus == 1  # Si es sinonimo, asocia el nombre_cientifico valido
      estatus = taxon.especies_estatus     # Checa si existe alguna sinonimia

      if estatus.length == 1  # Encontro el valido y solo es uno, como se esperaba
        begin  # Por si ya no existe ese taxon, suele pasar!
          taxon_valido = Especie.find(estatus.first.especie_id2)
          taxon_valido.asigna_categorias
          # Asigna el taxon valido al taxon original
          self.validacion[:taxon] = taxon_valido
          self.validacion[:taxon_valido] = true
        rescue
          self.validacion[:obs] = 'No hay un taxon valido para la coincidencia'
        end

      else  # No existe el valido o hay mas de uno >.>!
        self.validacion[:obs] = 'No hay un taxon valido para la coincidencia'
      end
    end  # End estatus = 1

    # Para saber si no era un sinonimo
    if validacion[:taxon_valido].present?
      self.validacion[:scat_estatus] = 'sinónimo'
    else
      self.validacion[:scat_estatus] = Especie::ESTATUS_SIGNIFICADO[validacion[:taxon].estatus]
    end
  end

  # Encuentra el mas parecido
  def encuentra_por_nombre
    puts "\n Encuentra record por nombre cientifico: #{fila['nombre_cientifico']}"
    # Evita que el nombre cientifico este vacio
    if fila['nombre_cientifico'].blank?
      self.validacion = {estatus: false, obs: 'El nombre cientifico está vacío'}
      return
    end

    taxones = Especie.where(nombre_cientifico: fila['nombre_cientifico'].strip)

    if taxones.length == 1  # Caso mas sencillo, coincide al 100 y solo es uno
      puts "\n\nCoincidio busqueda exacta"
      self.validacion = {taxon: taxones.first}
      coincide_familia_orden?
      return

    elsif taxones.length > 1  # Encontro el mismo nombre cientifico mas de una vez
      puts "\n\nCoincidio mas de uno directo en la base"
      self.validacion = {taxones: taxones}
      busca_recursivamente
      return

    else
      puts "\n\nTratando de encontrar concidencias con la base, separando el nombre"
      # Parte de expresiones regulares a ver si encuentra alguna coincidencia
      nombres = fila['nombre_cientifico'].limpiar.downcase.split(' ')

      taxones = if nombres.length == 2  # Especie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} % #{nombres[1]}'")
              elsif nombres.length == 3  # Infraespecie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} % #{nombres[1]} % #{nombres[2]}'")
              elsif nombres.length == 1 # Genero o superior
                Especie.where("nombre_cientifico LIKE '#{nombres[0]}'")
              end

      if taxones.present? && taxones.length == 1  # Caso mas sencillo
        self.validacion = {taxon: taxones.first, estatus: true}
        coincide_familia_orden?
        return

      elsif taxones.present? && taxones.length > 1  # Mas de una coincidencia
        self.validacion = {taxones: taxones}
        busca_recursivamente
        return

      else  # Lo buscamos con el fuzzy match y despues con el algoritmo levenshtein
        puts "\n\nTratando de encontrar concidencias con el fuzzy match"
        ids = FUZZY_NOM_CIEN.find(fila['nombre_cientifico'].limpia, limit=CONFIG.limit_fuzzy)

        if ids.present?
          taxones = Especie.caso_rango_valores('especies.id', ids.join(','))
          taxones_con_distancia = []

          taxones.each do |taxon|
            # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
            distancia = Levenshtein.distance(fila['nombre_cientifico'].strip.downcase, taxon.nombre_cientifico.limpiar.downcase)
            next if distancia > 2  # No cumple con la distancia
            taxones_con_distancia << taxon
          end

          if taxones_con_distancia.empty?
            puts "\n\nSin coincidencia"
            self.validacion = {estatus: false, obs: 'Sin coincidencias'}
            return
          else
            self.validacion = {taxones: taxones_con_distancia}
            busca_recursivamente
            return
          end

        else  # No hubo coincidencias con su nombre cientifico
          puts "\n\nSin coincidencia"
          self.validacion = {estatus: false, obs: 'Sin coincidencias'}
          return
        end
      end

    end  #Fin de las posibles coincidencias
  end

  def valida_campos
    puts "\n Validando campos en 30 seg ..."
    sleep(3)  # Es necesario el sleep ya que trata de leer el archivo antes de que lo haya escrito en disco
    self.excel_valido = []

    xlsx = Roo::Excelx.new(excel, packed: nil, file_warning: :ignore)
    @sheet = xlsx.sheet(0)  # toma la primera hoja por default

    @sheet.parse(cabecera).each_with_index do |f, index|
      next if index == 0
      self.fila = f
      encuentra_por_nombre

      if validacion[:estatus]  # Encontro por lo menos un nombre cientifico valido
        self.excel_valido << asocia_respuesta
      else # No encontro coincidencia con nombre cientifico, probamos con los ancestros, a tratar de coincidir
        # Para salir del programa con el mensaje original
        if validacion[:salir]
          self.excel_valido << asocia_respuesta
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
            self.excel_valido << asocia_respuesta
            break
          end
        end

        # Por si no hubo ningun valido
        if !validacion[:estatus]
          validacion[:obs] = 'Sin coincidencias'
          self.excel_valido << asocia_respuesta
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
            correcciones_hash["SCAT_Correccion#{campo.primera_en_mayuscula}"] = taxon.nombre.downcase == fila[campo].try(:downcase) ? nil : taxon.nombre
          else
            correcciones_hash["SCAT_Correccion#{campo.primera_en_mayuscula}"] = nil
          end

        else
          correcciones_hash["SCAT_Correccion#{campo.primera_en_mayuscula}"] = eval("taxon.x_#{campo}").try(:downcase) == fila[campo].try(:downcase) ? nil : eval("taxon.x_#{campo}")
        end

      else
        correcciones_hash["SCAT_Correccion#{campo.primera_en_mayuscula}"] = nil
      end
    end

    correcciones_hash
  end

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