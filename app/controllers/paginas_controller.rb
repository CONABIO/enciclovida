# Este controlador tiene la finalidad de hacer contenido por paginas, ej la lista de invasoras
class PaginasController < ApplicationController
  skip_before_action :set_locale

  layout Proc.new{['exoticas_invasoras_paginado'].include?(action_name) ? false : 'application'}

  # La pagina cuando entran por get
  def exoticas_invasoras
    lee_csv
  end

  # La resultados que provienen del paginado
  def exoticas_invasoras_paginado
    lee_csv
    render partial: 'exoticas_invasoras'
  end

 def buscar_especies
  termino = params[:q].to_s.downcase.strip
  limite = (params[:limit] || 10).to_i
  
  Rails.logger.info "=== BUSCAR ESPECIES ==="
  Rails.logger.info "Término: #{termino}"
  
  return render json: {resultados: [], total: 0} if termino.length < 2
  
  file = File.join(Rails.root, 'public', 'exoticas_invasoras', 'exoticas-invasoras.csv')
  
  unless File.exist?(file)
    Rails.logger.error "ARCHIVO NO ENCONTRADO: #{file}"
    return render json: {resultados: [], total: 0, error: "Archivo no encontrado"}
  end
  
  resultados = []
  
  begin
    # USAR EL MISMO ENCODING que en lee_csv
    CSV.foreach(file, headers: true) do |row|
      # Usar los mismos nombres de columnas que en lee_csv
      nombre_cientifico = (row['Nombre cientifico'] || row['Nombre científico'] || '').to_s
      nombre_comun = (row['Nombre común'] || row['Nombre comun'] || '').to_s
      
      # Depuración: mostrar primeros 5 nombres
      if resultados.empty? && rand < 0.01 # Solo ocasionalmente para no llenar logs
        Rails.logger.info "Ejemplo de nombre: #{nombre_cientifico}"
      end
      
      if nombre_cientifico.downcase.include?(termino)
        resultados << {
          nombre_cientifico: nombre_cientifico,
          nombre_comun: nombre_comun
        }
        
        Rails.logger.info "✓ Encontrado: #{nombre_cientifico}"
        break if resultados.size >= limite
      end
    end
    
    Rails.logger.info "Total resultados: #{resultados.size}"
    
    render json: {
      resultados: resultados,
      total: resultados.size,
      query: termino
    }
    
  rescue => e
    Rails.logger.error "ERROR: #{e.message}"
    Rails.logger.error e.backtrace.first(5)
    render json: {resultados: [], total: 0, error: e.message}
  end
end

  protected

  def lee_csv
    termino_busqueda = params[:nombre_cientifico].to_s.downcase.strip

    @tabla_exoticas = {}
    @tabla_exoticas[:datos] = []

    opciones_posibles
    opciones_seleccionadas

    file = File.join(Rails.root, 'public', 'exoticas_invasoras', 'exoticas-invasoras.csv')
  
    # RUTAS PARA LAS 3 CARPETAS DE PDFs
    meri_url = '/pdfs/exoticas_invasoras/MERI'
    meri_dir = File.join(Rails.root, 'public', meri_url)

    meri_extenso_url = '/pdfs/exoticas_invasoras/MERI_Extenso/'
    meri_extenso_dir = File.join(Rails.root, 'public', meri_extenso_url)
  
    extenso_url = '/pdfs/exoticas_invasoras/Extenso/'
    extenso_dir = File.join(Rails.root, 'public', extenso_url)
  
    instrumentos_url = '/pdfs/exoticas_invasoras/instrumentos_legales/'
    inst_dir = Rails.root.join('public', instrumentos_url)

    @por_pagina = 30
    @pagina = params[:pagina].present? ? params[:pagina].to_i : 1
  
    todos_datos = []
  
    CSV.foreach(file, headers: true) do |row|
      next unless condiciones_filtros(row)
    
      if termino_busqueda.present?
        nombre_cientifico = (row['Nombre cientifico'] || row['Nombre científico'] || '').to_s.downcase
        next unless nombre_cientifico.include?(termino_busqueda)
      end
    
      nombre = row['Nombre cientifico'] || row['Nombre científico'] || ''
      nombre_para_ordenar = nombre.to_s.downcase.strip
    
      todos_datos << {
        nombre_ordenar: nombre_para_ordenar,
        row_data: row,
        row_index: todos_datos.size
      }
    end
    
    todos_datos.sort_by! { |item| item[:nombre_ordenar] }
  
    @totales = todos_datos.size
  
    inicio = (@pagina - 1) * @por_pagina
    fin = [inicio + @por_pagina - 1, @totales - 1].min
  
    filas_a_procesar = todos_datos[inicio..fin] || []
  
    filas_a_procesar.each_with_index do |item, page_index|
      row = item[:row_data]
      datos = []

      rutas = []
      rutas << 'Liberación intencional' if row['Ruta_Liberación intencional'] == 'x'
      rutas << 'Escapes' if row['Ruta_Escapes'] == 'x'
      rutas << 'Contaminante' if row['Ruta_Contaminante'] == 'x'
      rutas << 'Polizón' if row['Ruta_Polizón'] == 'x'
      rutas << 'Creación de Corredores' if row['Ruta_Creación de Corredores'] == 'x'
      rutas << 'Independiente' if row['Ruta_Independiente'] == 'x'
      
      t = if row['enciclovida_id'].present?
        begin
          Especie.find(row['enciclovida_id'])
        rescue
          nil
        end
      end
      
      nombre = if t
        t.nombre_cientifico
      else
        row['Nombre cientifico'] || row['Nombre científico'] || ''
      end
      
      if t
        datos << t.adicional.try(:foto_principal)
        datos << t
      
        if familia = t.ancestors.left_joins(:categoria_taxonomica)
                    .where("#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} = 'familia'")
          datos << familia.first.nombre_cientifico
        else
          datos << nil
        end
        datos << row['Grupo']
      else
        creditos_fotos = row['Creditos Fotos'] || row['Créditos Fotos'] || row['Creditos fotos']
        if creditos_fotos.present?
          nombre_foto = "#{nombre}.jpg"
          foto = Rails.root.join('public', 'fotos_invasoras', nombre_foto)
          if File.exist?(foto)
            foto_url = "/fotos_invasoras/#{nombre_foto}"
            datos << foto_url
          else
            datos << nil
          end
        else
          datos << nil
        end
      
        datos << nombre
        datos << (row['Familia'] || row['familia'])
        datos << row['Grupo']
      end
    
      # BUSCAR PDFs
      pdfs_encontrados = []
    
      if nombre.present?
        nombre_busqueda = nombre.to_s.strip
      
        if File.directory?(meri_dir)
          pdfs_meri = buscar_pdfs_en_carpeta_plana(nombre_busqueda, meri_dir, meri_url, 'MERI')
          pdfs_encontrados.concat(pdfs_meri) if pdfs_meri.any?
        end
      
        if File.directory?(meri_extenso_dir)
          pdfs_meri_extenso = buscar_pdfs_en_carpeta_con_subcarpetas(nombre_busqueda, meri_extenso_dir, meri_extenso_url)
          pdfs_encontrados.concat(pdfs_meri_extenso) if pdfs_meri_extenso.any?
        end
      
        if File.directory?(extenso_dir)
          pdfs_extenso = buscar_pdfs_en_carpeta_plana(nombre_busqueda, extenso_dir, extenso_url, 'Extenso')
          pdfs_encontrados.concat(pdfs_extenso) if pdfs_extenso.any?
        end
        
        pdfs_encontrados.sort_by! { |pdf| pdf[:tipo] }
      end
    
      datos << (row['Ambiente'] || row['ambiente'])
      datos << (row['Origen'] || row['origen'])
      datos << (row['Presencia'] || row['presencia'])
      datos << (row['Estatus'] || row['estatus'])
    
      # Instrumentos legales - Manteniendo (género) con encoding correcto
      instrumentos = []
      regulada_por = row['Regulada por otros instrumentos'] || row['Instrumento legal'] || row['instrumento legal']
      if regulada_por.present?
        regulada_por.split('/').each do |inst|
          inst = inst.strip
          # Solo corregir encoding, NO eliminar (género)
          inst = corregir_codificacion(inst)
          pdf_inst_path = File.join(inst_dir, "#{inst}.pdf")
          if File.exist?(pdf_inst_path)
            pdf_inst = File.join(instrumentos_url, "#{inst}.pdf")
            instrumentos << { nombre: inst, pdf: pdf_inst }
          else
            # Intentar con nombre normalizado (sin espacios extras)
            inst_normalizado = inst.gsub(/\s+/, ' ')
            pdf_inst_path2 = File.join(inst_dir, "#{inst_normalizado}.pdf")
            if File.exist?(pdf_inst_path2)
              pdf_inst = File.join(instrumentos_url, "#{inst_normalizado}.pdf")
              instrumentos << { nombre: inst, pdf: pdf_inst }
            else
              instrumentos << { nombre: inst, pdf: nil }
            end
          end
        end
      end
    
      datos << instrumentos
      datos << pdfs_encontrados
      datos << rutas.join(', ')

      @tabla_exoticas[:datos] << datos
    end
  
    @paginas = (@totales % @por_pagina).zero? ? @totales / @por_pagina : (@totales / @por_pagina) + 1
  end

  private

  def buscar_pdfs_en_carpeta_plana(nombre_especie, carpeta_dir, carpeta_url, tipo_pdf)
    pdfs_encontrados = []
    
    nombre_busqueda_normalizado = nombre_especie.downcase.gsub(/[^a-z0-9]/, '')
    
    Dir.glob(File.join(carpeta_dir, "*.pdf")).each do |ruta_pdf|
      nombre_archivo = File.basename(ruta_pdf, '.pdf')
      nombre_archivo_normalizado = nombre_archivo.downcase.gsub(/[^a-z0-9]/, '')
      
      if nombre_busqueda_normalizado == nombre_archivo_normalizado ||
         nombre_busqueda_normalizado.include?(nombre_archivo_normalizado) ||
         nombre_archivo_normalizado.include?(nombre_busqueda_normalizado)
        
        pdfs_encontrados << {
          tipo: tipo_pdf,
          carpeta: tipo_pdf,
          ruta: File.join(carpeta_url, "#{nombre_archivo}.pdf"),
          nombre_archivo: "#{nombre_archivo}.pdf",
          encontrado: true
        }
      end
    end
    
    if pdfs_encontrados.empty?
      nombres_posibles = [
        nombre_especie,
        nombre_especie.gsub(' ', '_'),
        nombre_especie.gsub(' ', '-'),
        nombre_especie.downcase,
        nombre_especie.downcase.gsub(' ', '_'),
        nombre_especie.downcase.gsub(' ', '-'),
        nombre_especie.split(' ').first,
        nombre_especie.split(' ').first.downcase,
        nombre_especie.split(' ').map(&:downcase).join('_'),
        nombre_especie.split(' ').map(&:downcase).join('-')
      ].uniq
      
      nombres_posibles.each do |nombre_posible|
        ruta_pdf = File.join(carpeta_dir, "#{nombre_posible}.pdf")
        if File.exist?(ruta_pdf)
          pdfs_encontrados << {
            tipo: tipo_pdf,
            carpeta: tipo_pdf,
            ruta: File.join(carpeta_url, "#{nombre_posible}.pdf"),
            nombre_archivo: "#{nombre_posible}.pdf",
            encontrado: true
          }
        end
      end
    end
    
    pdfs_encontrados
  end

  def buscar_pdfs_en_carpeta_con_subcarpetas(nombre_especie, carpeta_dir, carpeta_url)
    pdfs_encontrados = []
    
    nombre_busqueda_normalizado = nombre_especie.downcase.gsub(/[^a-z0-9]/, '')
    
    nombres_subcarpeta_posibles = [
      nombre_especie,
      nombre_especie.gsub(' ', '_'),
      nombre_especie.gsub(' ', '-'),
      nombre_especie.downcase,
      nombre_especie.downcase.gsub(' ', '_'),
      nombre_especie.downcase.gsub(' ', '-'),
      nombre_especie.split('_').map(&:capitalize).join('_'),
      nombre_especie.split(' ').map(&:capitalize).join('_'),
      nombre_especie.split(' ').map(&:downcase).join('_'),
      nombre_especie.split(' ').map(&:downcase).join('-')
    ].uniq
    
    nombres_subcarpeta_posibles.each do |nombre_subcarpeta|
      ruta_subcarpeta = File.join(carpeta_dir, nombre_subcarpeta)
      
      if File.directory?(ruta_subcarpeta)
        Dir.glob(File.join(ruta_subcarpeta, "*.pdf")).each do |ruta_pdf|
          nombre_archivo = File.basename(ruta_pdf)
          tipo_documento = determinar_tipo_documento(nombre_archivo)
          
          pdfs_encontrados << {
            tipo: tipo_documento,
            carpeta: 'MERI_Extenso',
            ruta: File.join(carpeta_url, nombre_subcarpeta, nombre_archivo),
            nombre_archivo: nombre_archivo,
            encontrado: true,
            subcarpeta: nombre_subcarpeta
          }
        end
      end
    end
    
    if pdfs_encontrados.empty?
      Dir.glob(File.join(carpeta_dir, "*")).each do |ruta_item|
        next unless File.directory?(ruta_item)
        
        nombre_subcarpeta = File.basename(ruta_item)
        nombre_subcarpeta_normalizado = nombre_subcarpeta.downcase.gsub(/[^a-z0-9]/, '')
        
        if nombre_busqueda_normalizado.include?(nombre_subcarpeta_normalizado) ||
           nombre_subcarpeta_normalizado.include?(nombre_busqueda_normalizado)
          
          Dir.glob(File.join(ruta_item, "*.pdf")).each do |ruta_pdf|
            nombre_archivo = File.basename(ruta_pdf)
            tipo_documento = determinar_tipo_documento(nombre_archivo)
            
            pdfs_encontrados << {
              tipo: tipo_documento,
              carpeta: 'MERI_Extenso',
              ruta: File.join(carpeta_url, nombre_subcarpeta, nombre_archivo),
              nombre_archivo: nombre_archivo,
              encontrado: true,
              subcarpeta: nombre_subcarpeta
            }
          end
        end
      end
    end
    
    pdfs_encontrados
  end

  def determinar_tipo_documento(nombre_archivo)
    nombre_archivo_lower = nombre_archivo.downcase
    
    patrones_meri = ['meri', '_m.', '_m_', '-m.', '-m_', ' meri', '_meri', '-meri', 'meri_', 'meri-']
    patrones_extenso = ['extenso', '_e.', '_e_', '-e.', '-e_', ' extenso', '_extenso', '-extenso', 'extenso_', 'extenso-']
    
    patrones_meri.each do |patron|
      return 'MERI' if nombre_archivo_lower.include?(patron)
    end
    
    patrones_extenso.each do |patron|
      return 'Extenso' if nombre_archivo_lower.include?(patron)
    end
    
    'MERI_Extenso'
  end

  def opciones_posibles
    @select = {}
    @select[:grupos] = ['Algas y protoctistas', 'Anfibios', 'Arácnidos', 'Aves', 'Crustáceos', 'Hongos', 'Insectos', 'Mamíferos', 'Moluscos', 'Otros invertebrados', 'Peces', 'Plantas', 'Reptiles', 'Virus y bacterias']
    @select[:origenes] = ['Criptogénica', 'Exótica', 'Nativa', 'Se desconoce']
    @select[:presencias] = ['Ausente', 'Presente', 'Se desconoce']
    @select[:instrumentos_legales] = obtener_instrumentos_desde_csv
    @select[:ambientes] = ['Dulceacuícola', 'Marino', 'Salobre', 'Terrestre', 'Se desconoce']
    @select[:estatus] = ['Invasora']
    @select[:fichas] = ['Sí', 'No']
    @select[:rutas] = [
      'Liberación intencional',
      'Escapes',
      'Contaminante',
      'Polizón',
      'Creación de Corredores',
      'Independiente'
    ]
  end
  
  def obtener_instrumentos_desde_csv
    csv_path = Rails.root.join('public', 'exoticas_invasoras', 'exoticas-invasoras.csv')
    instrumentos = Set.new
    
    encodings_to_try = ['UTF-8', 'ISO-8859-1:UTF-8', 'Windows-1252:UTF-8']
    
    encodings_to_try.each do |encoding|
      begin
        CSV.foreach(csv_path, headers: true, encoding: encoding) do |row|
          valor = row['Regulada por otros instrumentos'] || row['Instrumento legal'] || row['instrumento legal']
          
          if valor.present?
            valor.to_s.split('/').each do |inst|
              inst = inst.strip
              # Solo corregir encoding, NO eliminar (género)
              inst = corregir_codificacion(inst)
              instrumentos.add(inst) unless inst.blank?
            end
          end
        end
        break
      rescue ArgumentError, Encoding::InvalidByteSequenceError => e
        puts "Error con encoding #{encoding}: #{e.message}"
        next
      end
    end
    
    if instrumentos.empty?
      instrumentos = Set.new([
        'Acuerdo EEI SEMARNAT, Plagas bajo vigilancia Senasica 2025',
        'LISTA DE PLAGAS BAJO VIGILANCIA, 2025',
        'Lista oficial invasoras México',
        'Lista oficial invasoras México NOM-002-FITO-2000',
        'Lista oficial invasoras México NOM-013-SEMARNAT-2020',
        'Lista oficial invasoras México NOM-016-SEMARNAT-2013',
        'Lista oficial invasoras México NOM-043-FITO-1999',
        'Lista oficial invasoras México NOM-059-SEMARNAT-2010',
        'Lista oficial invasoras México Plagas bajo vigilancia Senasica 2025',
        'Lista plagas bajo vigilancia 2025',
        'Lista Plagas en Vigilancia Activa Senasica',
        'NOM-005-FITO-1995; LISTA DE PLAGAS BAJO VIGILANCIA, 2025',
        'NOM-010-FITO-1995, LISTA DE PLAGAS BAJO VIGILANCIA, 2025',
        'NOM-013-SEMARNAT-2020',
        'NOM-013-SEMARNAT-2020; Lista Plagas en Vigilancia Activa Senasica 2025',
        'NOM-014-FITO-1995',
        'NOM-016-SEMARNAT-2013',
        'NOM-043-FITO-1999',
        'Plagas bajo vigilancia Senasica 2025'
      ])
    end
    
    instrumentos.to_a.sort
  end
  
  def corregir_codificacion(texto)
    return texto if texto.blank?
    
    # Asegurar encoding UTF-8
    texto = texto.dup.force_encoding('UTF-8')
    
    # Corregir caracteres comunes mal codificados
    correcciones = {
      'Ã©' => 'é',
      'Ã¡' => 'á',
      'Ã³' => 'ó',
      'Ãº' => 'ú',
      'Ã±' => 'ñ',
      'Ã¼' => 'ü',
      'Ã' => 'Á',
      'Ã' => 'É',
      'Ã' => 'Ó',
      'Ã' => 'Ú',
      'Ã' => 'Ñ',
      'Â' => '',
      'Ã' => 'á',
      '©' => 'é',
      '°' => 'ó',
      'º' => 'ú'
    }
    
    correcciones.each do |mal, bien|
      texto = texto.gsub(mal, bien)
    end
    
    # Asegurar que (género) se vea correctamente (pero NO se elimina)
    texto = texto.gsub(/\(g[Ã©©]nero\)/i, '(género)')
    texto = texto.gsub(/\(g[eé]nero\)/i, '(género)')
    
    texto.strip
  end

  def opciones_seleccionadas
    @selected = {}
    
    if params[:ruta].present?
      @selected[:ruta] = {
        valor: params[:ruta].to_s.strip,
        nom_campo: params[:ruta].to_s.strip
      }
    end

    if params[:nombre_cientifico].present?
      @selected[:nombre_cientifico] = {
        valor: params[:nombre_cientifico].to_s.strip,
        nom_campo: 'Nombre cientifico'
      }
    end
    
    if params[:grupo].present?
      @selected[:grupo] = {
        valor: params[:grupo].to_s.strip,
        nom_campo: 'Grupo'
      }
    end

    if params[:origen].present?
      @selected[:origen] = {
        valor: params[:origen].to_s.strip,
        nom_campo: 'Origen'
      }
    end

    if params[:presencia].present?
      @selected[:presencia] = {
        valor: params[:presencia].to_s.strip,
        nom_campo: 'Presencia'
      }
    end

    if params[:instrumento].present?
      @selected[:instrumento] = {
        valor: params[:instrumento].to_s.strip,
        nom_campo: 'Regulada por otros instrumentos'
      }
    end

    if params[:ambiente].present?
      @selected[:ambiente] = {
        valor: params[:ambiente].to_s.strip,
        nom_campo: 'Ambiente'
      }
    end

    if params[:estatus].present?
      @selected[:estatus] = {
        valor: params[:estatus].to_s.strip,
        nom_campo: 'Estatus'
      }
    end

    if params[:ficha].present?
      @selected[:ficha] = {
        valor: params[:ficha].to_s.strip,
        nom_campo: 'Ficha'
      }
    end
  end

  def condiciones_filtros(row)
    return true if @selected.empty?
    
    @selected.each do |campo, v|
      if campo == :ruta
        ruta_real = case v[:valor]
        when 'Liberación intencional'
          'Ruta_Liberación intencional'
        when 'Escapes'
          'Ruta_Escapes'
        when 'Contaminante'
          'Ruta_Contaminante'
        when 'Polizón'
          'Ruta_Polizón'
        when 'Creación de Corredores'
          'Ruta_Creación de Corredores'
        when 'Independiente'
          'Ruta_Independiente'
        else
          v[:valor]
        end
        
        valor_csv = row[ruta_real].to_s.strip.downcase
        return false unless valor_csv == 'x'
        next
      end
      
      if campo == :nombre_cientifico
        termino = v[:valor].to_s.downcase.strip
        nombre_cientifico = (row['Nombre cientifico'] || row['Nombre científico'] || '').to_s.downcase.strip
        next if termino.blank?
        return false unless nombre_cientifico.include?(termino)
        next
      end
      
      if v[:nom_campo] == 'Ficha'
        if v[:valor] == 'Sí'
          return false if row['Ficha'].blank?
        else
          return false if row['Ficha'].present?
        end
        next
      end
      
      if campo == :instrumento
        valor_seleccionado = v[:valor].to_s.strip
        valor_csv = (row['Regulada por otros instrumentos'] || row['Instrumento legal'] || '').to_s.strip
        
        next if valor_seleccionado.blank?
        return false if valor_csv.blank?
        
        # Normalizar para comparación (sin eliminar género)
        seleccionado_norm = normalizar_para_comparacion(valor_seleccionado)
        csv_norm = normalizar_para_comparacion(valor_csv)
        
        return false unless csv_norm.include?(seleccionado_norm) || seleccionado_norm.include?(csv_norm)
        next
      end
      
      valor_seleccionado = v[:valor].to_s.strip.downcase
      valor_csv = row[v[:nom_campo]].to_s.strip.downcase
      
      return false if valor_csv.blank?
      
      if valor_csv.include?('/')
        valores_csv = valor_csv.split('/').map(&:strip)
        return false unless valores_csv.include?(valor_seleccionado)
      else
        return false unless valor_csv == valor_seleccionado
      end
    end
    
    true
  end
  
  def normalizar_para_comparacion(texto)
    return '' if texto.blank?
    
    # Normalizar para comparación pero mantener la esencia del texto
    texto = texto.to_s.dup
    texto = corregir_codificacion(texto)
    texto = texto.downcase.strip
    texto = texto.gsub(/\s+/, ' ')
    texto = texto.gsub(/[.,;:]$/, '')
    
    texto
  end
end