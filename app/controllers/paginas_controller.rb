# Este controlador tiene la finalidad de hacer contenido por paginas, ej la lista de invasoras
class PaginasController < ApplicationController
  skip_before_action :set_locale
  layout Proc.new{['exoticas_invasoras_paginado'].include?(action_name) ? false : 'application'}

  def polinizadores
    tipo = params[:tipo_polinizador] || 'todos_interaccion'
    clase = params[:clase_polinizador]
    pagina = (params[:pagina] || 1).to_i
    por_pagina = (params[:por_pagina] || 20).to_i

    @taxones = TransformaNombre.buscar_polinizadores_por_tipo(tipo, pagina, por_pagina, clase)
    @totales = TransformaNombre.contar_polinizadores_por_tipo(tipo, clase)
    @por_categoria = []

    response.headers['x-total-entries'] = @totales.to_s if @totales > 0

    if request.xhr?
      render partial: 'paginas/resultados_polinizadores', layout: false
    else
      render 'paginas/polinizadores'
    end
  end

  def exoticas_invasoras
    lee_csv
  end

  def exoticas_invasoras_paginado
    lee_csv
    render partial: 'exoticas_invasoras'
  end

 def buscar_especies
  termino = params[:q].to_s.downcase.strip
  limite = (params[:limit] || 10).to_i
  return render json: {resultados: [], total: 0} if termino.length < 2
  file = File.join(Rails.root, 'public', 'exoticas_invasoras', 'exoticas-invasoras.csv')
  csv = CSV.read(file, headers: true)
  nombre_columna = csv.headers.find do |h|
    h.to_s.downcase.include?('nombre')
  end
  unless File.exist?(file)
    return render json: {resultados: [], total: 0, error: "Archivo no encontrado"}
  end
  resultados = []
  begin
    CSV.foreach(file, headers: true) do |row|
      nombre_cientifico = row[nombre_columna].to_s
      if nombre_cientifico.downcase.include?(termino)
        resultados << {nombre_cientifico: nombre_cientifico}
        break if resultados.size >= limite
      end
    end    
    render json: {
      resultados: resultados,
      total: resultados.size,
      query: termino
    }
    rescue => e
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
    csv = CSV.read(file, headers: true)
    col_nombre_cientifico = csv.headers.find do |h|
      h.to_s.downcase.include?('nombre')
    end
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
    grupos = Hash.new(0)
    CSV.foreach(csv_path, headers: true) do |row|
      puts row['ficha'] if row['ficha'].present?
    end
    CSV.foreach(file, headers: true) do |row|
      nombre_cientifico = row[col_nombre_cientifico].to_s.downcase.strip
      next unless condiciones_filtros(row)
      if termino_busqueda.present?
        nombre_cientifico = (row[col_nombre_cientifico] || row['Nombre cientifico'] || row['Nombre científico'] || '').to_s.downcase
        next unless nombre_cientifico.include?(termino_busqueda)
      end
      nombre = row[col_nombre_cientifico] || row['Nombre cientifico'] || row['Nombre científico'] || ''
      nombre_para_ordenar = nombre.to_s.downcase.strip
      if @selected[:ficha].present?
        nombre = row[col_nombre_cientifico] || ''
        pdfs_tmp = []
        if nombre.present?
          pdfs_tmp.concat(
            buscar_pdfs_en_carpeta_plana(nombre, meri_dir, meri_url, 'MERI')
          ) if File.directory?(meri_dir)

          pdfs_tmp.concat(
            buscar_pdfs_en_carpeta_con_subcarpetas(nombre, meri_extenso_dir, meri_extenso_url)
          ) if File.directory?(meri_extenso_dir)

          pdfs_tmp.concat(
            buscar_pdfs_en_carpeta_plana(nombre, extenso_dir, extenso_url, 'Extenso')
          ) if File.directory?(extenso_dir)
        end
        tiene_ficha = pdfs_tmp.any? { |pdf| pdf[:encontrado] }
        if @selected[:ficha][:valor] == 'Sí'
          next unless tiene_ficha
        else
          next if tiene_ficha
        end
      end
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
       row[col_nombre_cientifico] ||  row['Nombre cientifico'] || row['Nombre científico'] || ''
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
    
      datos << corregir_codificacion(row['Ambiente'] || row['ambiente'])
      datos << corregir_codificacion(row['Origen'] || row['origen'])
      datos << corregir_codificacion(row['Presencia'] || row['presencia'])
      datos << corregir_codificacion(row['Estatus'] || row['estatus'])
    
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

  def csv_path
    Rails.root.join(
      'public',
      'exoticas_invasoras',
      'exoticas-invasoras.csv'
    )
  end

  def obtener_rutas_desde_csv
    csv = CSV.read(csv_path, headers: true)
    csv.headers
      .select { |h| h.to_s.start_with?('Ruta_') }
      .map do |h|
        corregir_codificacion(
          h.sub('Ruta_', '')
        )
      end
      .sort
  end

  def obtener_valores_unicos_csv(columna)
    valores = Set.new
    CSV.foreach(csv_path, headers: true) do |row|
      valor = corregir_codificacion(
        row[columna].to_s.strip
      )
      valores.add(valor) unless valor.blank?
    end
    valores.to_a.sort
  end

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
    @select.merge!(cargar_opciones_desde_csv)
    @select[:fichas] = ['Sí', 'No']
        

  end

 def cargar_opciones_desde_csv
  {
    grupos:      obtener_valores_unicos_csv('Grupo'),
    ambientes:   obtener_valores_unicos_csv('Ambiente'),
    origenes:    obtener_valores_unicos_csv('Origen'),
    presencias:  obtener_valores_unicos_csv('Presencia'),
    estatus:     obtener_valores_unicos_csv('Estatus'),
    instrumentos_legales: obtener_valores_unicos_csv('Instrumento legal'),
    rutas: obtener_rutas_desde_csv
  }
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
        next
      end
      if campo == :ficha
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
      
      valor_seleccionado = corregir_codificacion(v[:valor].to_s.strip).downcase
      valor_csv = corregir_codificacion(row[v[:nom_campo]].to_s.strip).downcase
            
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