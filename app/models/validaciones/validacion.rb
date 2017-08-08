# Modelo sin tabla, solo para automatizar la validacion de archivos excel
class Validacion < ActiveRecord::Base

  belongs_to :usuario

  # El excel que subio, la cabecera del excel, la fila en cuestion del excel y la respuesta de alguna consulta, y el excel de respuesta
  attr_accessor :excel, :sheet, :cabecera, :fila, :validacion, :excel_validado, :nombre_cientifico, :archivo_copia

  FORMATOS_PERMITIDOS = %w(application/vnd.openxmlformats-officedocument.spreadsheetml.sheet)
  #FORMATOS_PERMITIDOS = %w(application/vnd.openxmlformats-officedocument.spreadsheetml.sheet text/csv text/plain)

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

  # Inicializa las variables
  def initialize
    self.excel_validado = []
    self.validacion = {}
  end

  def escribe_excel
    xlsx = RubyXL::Parser.parse(excel)  # El excel con su primera sheet
    sheet = xlsx[0]
    fila = 1  # Empezamos por la cabecera

    excel_validado.each do |h|
      columna = sheet.last_column  # Desde la columna donde empieza

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
      #coincide_familia_orden?

      # estamos seguros que no hay coincidencias, salimos
      return if validacion[:salir]

      if validacion[:estatus]
        validacion[:msg] = "Orig: #{fila['nombre_cientifico']}; Enciclo: #{taxon.nombre_cientifico}"
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
      validacion[:msg] = 'Sin coincidencias'
      validacion[:salir] = true
      return
    end

    if fila['familia'].present?  # Si escribio la familia en el excel entonces debe de coincidir
      if fila['familia'].downcase.strip == taxon.x_familia.downcase.strip
        validacion[:estatus] = true
      else
        validacion[:estatus] = false
        validacion[:msg] = "No coincidio la famila - Orig: #{fila['familia']}; Enciclo: #{taxon.x_familia}"
        validacion[:salir] = true
      end
    elsif fila['orden'].present?  # Si escribio el orden
      if fila['orden'].downcase.strip == taxon.x_orden.downcase.strip
        validacion[:estatus] = true
      else
        validacion[:estatus] = false
        validacion[:msg] = "No coincidio el orden - Orig: #{fila['orden']}; Enciclo: #{taxon.x_orden}"
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
          self.validacion[:msg] = 'No hay un taxon valido para la coincidencia'
        end

      else  # No existe el valido o hay mas de uno >.>!
        self.validacion[:msg] = 'No hay un taxon valido para la coincidencia'
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
    puts "\n Encuentra record por nombre cientifico: #{nombre_cientifico}"
    # Evita que el nombre cientifico este vacio
    if nombre_cientifico.blank?
      self.validacion = {estatus: false, msg: 'El nombre cientifico está vacío'}
      return
    end

    taxones = Especie.where(nombre_cientifico: nombre_cientifico.strip)

    if taxones.length == 1  # Caso mas sencillo, coincide al 100 y solo es uno
      puts "\n\nCoincidio busqueda exacta"
      self.validacion = {estatus: true, taxon: taxones.first, msg: 'Búsqueda exacta'}
      #coincide_familia_orden?
      return

    elsif taxones.length > 1  # Encontro el mismo nombre cientifico mas de una vez
      puts "\n\nCoincidio mas de uno directo en la base"
      self.validacion = {taxones: taxones, msg: 'Coincidio más de uno'}
      #busca_recursivamente
      return

    else
      puts "\n\nTratando de encontrar concidencias con la base, separando el nombre"
      # Parte de expresiones regulares a ver si encuentra alguna coincidencia
      nombres = nombre_cientifico.limpiar.downcase.split(' ')

      taxones = if nombres.length == 2  # Especie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} % #{nombres[1]}'")
              elsif nombres.length == 3  # Infraespecie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} % #{nombres[1]} % #{nombres[2]}'")
              elsif nombres.length == 1 # Genero o superior
                Especie.where("nombre_cientifico LIKE '#{nombres[0]}'")
              end

      if taxones.present? && taxones.length == 1  # Caso mas sencillo
        self.validacion = {estatus: true, taxon: taxones.first, msg: 'Búsqueda exacta'}
        #coincide_familia_orden?
        return

      elsif taxones.present? && taxones.length > 1  # Mas de una coincidencia
        self.validacion = {taxones: taxones, msg: 'Coincidio más de uno'}
        #busca_recursivamente
        return

      else  # Lo buscamos con el fuzzy match y despues con el algoritmo levenshtein
        puts "\n\nTratando de encontrar concidencias con el fuzzy match"
        ids = FUZZY_NOM_CIEN.find(nombre_cientifico.limpia, limit=CONFIG.limit_fuzzy)

        if ids.present?
          taxones = Especie.caso_rango_valores('especies.id', ids.join(','))
          taxones_con_distancia = []

          taxones.each do |taxon|
            # Si la distancia entre palabras es menor a 3 que muestre la sugerencia
            distancia = Levenshtein.distance(nombre_cientifico.strip.downcase, taxon.nombre_cientifico.limpiar.downcase)
            next if distancia > 2  # No cumple con la distancia
            taxones_con_distancia << taxon
          end

          if taxones_con_distancia.empty?
            puts "\n\nSin coincidencia"
            self.validacion = {estatus: false, msg: 'Sin coincidencias'}
            return
          else
            if taxones_con_distancia.length == 1
              self.validacion = {estatus: true, taxon: taxones_con_distancia.first, msg: 'Búsqueda similar'}
              return
            else
              self.validacion = {taxones: taxones_con_distancia, msg: 'Coincidio más de uno'}
              #busca_recursivamente
            end
          end

        else  # No hubo coincidencias con su nombre cientifico
          puts "\n\nSin coincidencia"
          self.validacion = {estatus: false, msg: 'Sin coincidencias'}
          return
        end
      end

    end  #Fin de las posibles coincidencias
  end

  def dame_sheet
    puts "\n Validando campos en 3 seg ..."
    sleep(3)  # Es necesario el sleep ya que trata de leer el archivo antes de que lo haya escrito en disco

    xlsx = Roo::Excelx.new(excel, packed: nil, file_warning: :ignore)
    self.sheet = xlsx.sheet(0)  # toma la primera hoja por default
  end

  def valida_excel
    dame_sheet
  end
end