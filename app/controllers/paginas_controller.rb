# Este controlador tiene la finalidad de hacer contenido por paginas, ej la lista de invasoras
class PaginasController < ApplicationController
  skip_before_action :set_locale

  layout Proc.new{['exoticas_invasoras_paginado'].include?(action_name) ? false : 'application'}

  # La pagina cuando entran por get
  def exoticas_invasoras
    lee_csv
    @tabla_exoticas[:cabeceras] = ['', 'Nombre científico', 'Familia', 'Grupo', 'Ambiente',
                                   'Origen', 'Presencia', 'Estatus', 'Instrumento legal', 'Ficha']
  end

  # La resultados que provienen del paginado
  def exoticas_invasoras_paginado
    lee_csv
    render partial: 'exoticas_invasoras'
  end

 def buscar_especies
    termino = params[:q].to_s.downcase.strip
    limite = (params[:limit] || 10).to_i
    
    return render json: {resultados: [], total: 0} if termino.length < 2
    
    file = File.join(Rails.root, 'public', 'exoticas_invasoras', 'exoticas-invasoras.csv')
    resultados = []
    
    CSV.foreach(file, headers: true) do |row|
      nombre_cientifico = (row['Nombre cientifico'] || row['Nombre científico'] || '').to_s.downcase
      
      if nombre_cientifico.include?(termino)
        resultados << {
          nombre_cientifico: row['Nombre cientifico'] || row['Nombre científico'],
          nombre_comun: row['Nombre común'] || row['Nombre comun'] || ''
        }
        
        break if resultados.size >= limite
      end
    end
    
    resultados.sort_by! { |r| r[:nombre_cientifico].to_s.downcase }
    
    render json: {resultados: resultados, total: resultados.size}
  end


  protected

  # En tu PaginasController, agrega solo este método nuevo:

  def lee_csv
    termino_busqueda = params[:nombre_cientifico].to_s.downcase.strip

    @tabla_exoticas = {}
    @tabla_exoticas[:datos] = []

    opciones_posibles
    opciones_seleccionadas

    file = File.join(Rails.root, 'public', 'exoticas_invasoras', 'exoticas-invasoras.csv')
  
    # RUTAS PARA LAS 3 CARPETAS DE PDFs
    # Carpeta 1: MERI
    meri_url = '/pdfs/exoticas_invasoras/MERI'
    meri_dir = File.join(Rails.root,'public',meri_url )

  
    # Carpeta 2: MERI_Extenso
    meri_extenso_url = '/pdfs/exoticas_invasoras/MERI_Extenso/'
    meri_extenso_dir = File.join(Rails.root,'public', meri_extenso_url)
  
    # Carpeta 3: Extenso
    extenso_url = '/pdfs/exoticas_invasoras/Extenso/'
    extenso_dir = File.join(Rails.root,'public', extenso_url)
  
    # URLs para instrumentos legales
    instrumentos_url = '/pdfs/exoticas_invasoras/instrumentos_legales/'
    inst_dir = Rails.root.join('public', instrumentos_url)

    # Leer y procesar SOLO los datos necesarios para la página actual
    @por_pagina = 30
    @pagina = params[:pagina].present? ? params[:pagina].to_i : 1
  
    # Opción 1: Usar CSV con streaming (más eficiente para archivos grandes)
    todos_datos = []
  
    # Primera pasada: recolectar solo los datos que pasan los filtros
    CSV.foreach(file, headers: true) do |row|
      next unless condiciones_filtros(row)
    
      if termino_busqueda.present?
        nombre_cientifico = (row['Nombre cientifico'] || row['Nombre científico'] || '').to_s.downcase
        next unless nombre_cientifico.include?(termino_busqueda)
      end
    
      # Determinar nombre para ordenar (solo esto, no todo el procesamiento)
      nombre = row['Nombre cientifico'] || row['Nombre científico'] || ''
      nombre_para_ordenar = nombre.to_s.downcase.strip
    
      # Guardar mínimo de información para ordenar
      todos_datos << {
        nombre_ordenar: nombre_para_ordenar,
        row_data: row,
        row_index: todos_datos.size
      }
    end
    # ORDENAR solo la lista ligera de nombres
    todos_datos.sort_by! { |item| item[:nombre_ordenar] }
  
    @totales = todos_datos.size
  
    # Calcular qué filas mostrar en esta página
    inicio = (@pagina - 1) * @por_pagina
    fin = [inicio + @por_pagina - 1, @totales - 1].min
  
    # Segunda pasada: procesar solo las filas de la página actual
    filas_a_procesar = todos_datos[inicio..fin] || []
  
    filas_a_procesar.each_with_index do |item, page_index|
      row = item[:row_data]
      datos = []
      # Buscar en Especie si existe
      t = if row['enciclovida_id'].present?
        begin
          Especie.find(row['enciclovida_id'])
        rescue
          nil
        end
      end
      # Determinar nombre final
      nombre = if t
        t.nombre_cientifico
      else
        row['Nombre cientifico'] || row['Nombre científico'] || ''
      end
      # Procesar como antes, pero solo para estas filas
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
        # Foto alternativa
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
    
      # ============================================
      # BUSCAR PDFs EN LAS 3 CARPETAS
      # ============================================
      pdfs_encontrados = []
    
      if nombre.present?
        # Normalizar nombre para búsqueda
        nombre_busqueda = nombre.to_s.strip
        nombre_busqueda_normalizado = nombre_busqueda.downcase.gsub(/[^a-z0-9]/, '')
      
        # BUSCAR EN MERI (estructura plana)
        if File.directory?(meri_dir)
          pdf_meri = buscar_pdf_en_carpeta_plana(nombre_busqueda, meri_dir, meri_url, 'MERI')
          pdfs_encontrados << pdf_meri if pdf_meri
        end
      
        # BUSCAR EN MERI_Extenso (con subcarpetas)
        if File.directory?(meri_extenso_dir)
          pdf_meri_extenso = buscar_pdf_en_carpeta_con_subcarpetas(nombre_busqueda, meri_extenso_dir, meri_extenso_url, 'MERI_Extenso')
          pdfs_encontrados << pdf_meri_extenso if pdf_meri_extenso
        end
      
        # BUSCAR EN Extenso (estructura plana)
        if File.directory?(extenso_dir)
          pdf_extenso = buscar_pdf_en_carpeta_plana(nombre_busqueda, extenso_dir, extenso_url, 'Extenso')
          pdfs_encontrados << pdf_extenso if pdf_extenso
        end
      end
    
      # ============================================
      # FIN DE BÚSQUEDA DE PDFs
      # ============================================
    
      # Resto de campos
      datos << (row['Ambiente'] || row['ambiente'])
      datos << (row['Origen'] || row['origen'])
      datos << (row['Presencia'] || row['presencia'])
      datos << (row['Estatus'] || row['estatus'])
    
      # Instrumentos
      instrumentos = []
      regulada_por = row['Regulada por otros instrumentos'] || row['Instrumento legal'] || row['instrumento legal']
      if regulada_por.present?
        regulada_por.split('/').each do |inst|
          inst = inst.strip
          pdf_inst_path = File.join(inst_dir, "#{inst}.pdf")
          if File.exist?(pdf_inst_path)
            pdf_inst = File.join(instrumentos_url, "#{inst}.pdf")
            instrumentos << { nombre: inst, pdf: pdf_inst }
          else
            instrumentos << { nombre: 'No existe pdf', pdf: nil }
          end
        end
      end
    
      datos << instrumentos
      datos << pdfs_encontrados  # Array de PDFs encontrados
    
      @tabla_exoticas[:datos] << datos
    end
  
    @paginas = (@totales % @por_pagina).zero? ? @totales / @por_pagina : (@totales / @por_pagina) + 1
  
    # Cache para mejor performance si es necesario
    Rails.cache.write("exoticas_ordenadas_#{@filtros_cache_key}", todos_datos, expires_in: 1.hour) if @filtros_cache_key
  end

# ============================================
# MÉTODOS HELPER PARA BÚSQUEDA DE PDFs
# ============================================

private

# Método para buscar PDF en carpeta plana (MERI y Extenso)
def buscar_pdf_en_carpeta_plana(nombre_especie, carpeta_dir, carpeta_url, tipo_pdf)
  # Generar posibles nombres de archivo
  nombres_posibles = [
    nombre_especie,
    nombre_especie.gsub(' ', '_'),
    nombre_especie.gsub(' ', '-'),
    nombre_especie.downcase,
    nombre_especie.downcase.gsub(' ', '_'),
    nombre_especie.downcase.gsub(' ', '-'),
    nombre_especie.split(' ').first,  # Solo género
    nombre_especie.split(' ').first.downcase
  ].uniq
  
  # Buscar por nombre exacto
  nombres_posibles.each do |nombre_posible|
    ruta_pdf = File.join(carpeta_dir, "#{nombre_posible}.pdf")
    if File.exist?(ruta_pdf)
      return {
        tipo: tipo_pdf,
        carpeta: tipo_pdf,
        ruta: File.join(carpeta_url, "#{nombre_posible}.pdf"),
        nombre_archivo: "#{nombre_posible}.pdf",
        encontrado: true
      }
    end
  end
  
  # Si no se encontró por nombre exacto, buscar coincidencias parciales
  nombre_busqueda_normalizado = nombre_especie.downcase.gsub(/[^a-z0-9]/, '')
  
  Dir.glob(File.join(carpeta_dir, "*.pdf")).each do |ruta_pdf|
    nombre_archivo = File.basename(ruta_pdf, '.pdf')
    nombre_archivo_normalizado = nombre_archivo.downcase.gsub(/[^a-z0-9]/, '')
    
    # Coincidencia parcial
    if nombre_busqueda_normalizado.include?(nombre_archivo_normalizado) ||
       nombre_archivo_normalizado.include?(nombre_busqueda_normalizado)
      
      return {
        tipo: tipo_pdf,
        carpeta: tipo_pdf,
        ruta: File.join(carpeta_url, "#{nombre_archivo}.pdf"),
        nombre_archivo: "#{nombre_archivo}.pdf",
        encontrado: true
      }
    end
  end
  
  nil
end

# Método para buscar PDF en carpeta con subcarpetas (MERI_Extenso)
def buscar_pdf_en_carpeta_con_subcarpetas(nombre_especie, carpeta_dir, carpeta_url, tipo_pdf)
  # Generar posibles nombres de subcarpeta
  nombres_subcarpeta_posibles = [
    nombre_especie,
    nombre_especie.gsub(' ', '_'),
    nombre_especie.gsub(' ', '-'),
    nombre_especie.downcase,
    nombre_especie.downcase.gsub(' ', '_'),
    nombre_especie.downcase.gsub(' ', '-'),
    nombre_especie.split('_').map(&:capitalize).join('_'),  # Capitalizado con guión bajo
    nombre_especie.split(' ').map(&:capitalize).join('_')   # Capitalizado con espacio
  ].uniq
  
  # Buscar subcarpeta exacta
  nombres_subcarpeta_posibles.each do |nombre_subcarpeta|
    ruta_subcarpeta = File.join(carpeta_dir, nombre_subcarpeta)
    
    if File.directory?(ruta_subcarpeta)
      # Buscar PDF dentro de la subcarpeta
      # Opción 1: PDF con mismo nombre que la subcarpeta
      ruta_pdf = File.join(ruta_subcarpeta, "#{nombre_subcarpeta}.pdf")
      if File.exist?(ruta_pdf)
        return {
          tipo: tipo_pdf,
          carpeta: tipo_pdf,
          ruta: File.join(carpeta_url, nombre_subcarpeta, "#{nombre_subcarpeta}.pdf"),
          nombre_archivo: "#{nombre_subcarpeta}.pdf",
          encontrado: true
        }
      end
      
      # Opción 2: Cualquier PDF dentro de la subcarpeta
      pdfs_en_subcarpeta = Dir.glob(File.join(ruta_subcarpeta, "*.pdf"))
      if pdfs_en_subcarpeta.any?
        # Tomar el primer PDF
        primer_pdf = pdfs_en_subcarpeta.first
        nombre_archivo = File.basename(primer_pdf)
        
        return {
          tipo: tipo_pdf,
          carpeta: tipo_pdf,
          ruta: File.join(carpeta_url, nombre_subcarpeta, nombre_archivo),
          nombre_archivo: nombre_archivo,
          encontrado: true
        }
      end
    end
  end
  
  # Si no se encontró subcarpeta exacta, buscar coincidencias parciales
  nombre_busqueda_normalizado = nombre_especie.downcase.gsub(/[^a-z0-9]/, '')
  
  # Listar todas las subcarpetas
  Dir.glob(File.join(carpeta_dir, "*")).each do |ruta_item|
    next unless File.directory?(ruta_item)
    
    nombre_subcarpeta = File.basename(ruta_item)
    nombre_subcarpeta_normalizado = nombre_subcarpeta.downcase.gsub(/[^a-z0-9]/, '')
    
    # Coincidencia parcial
    if nombre_busqueda_normalizado.include?(nombre_subcarpeta_normalizado) ||
       nombre_subcarpeta_normalizado.include?(nombre_busqueda_normalizado)
      
      # Buscar PDF dentro de esta subcarpeta
      pdfs_en_subcarpeta = Dir.glob(File.join(ruta_item, "*.pdf"))
      if pdfs_en_subcarpeta.any?
        primer_pdf = pdfs_en_subcarpeta.first
        nombre_archivo = File.basename(primer_pdf)
        
        return {
          tipo: tipo_pdf,
          carpeta: tipo_pdf,
          ruta: File.join(carpeta_url, nombre_subcarpeta, nombre_archivo),
          nombre_archivo: nombre_archivo,
          encontrado: true
        }
      end
    end
  end
  
  nil
end

  def opciones_posibles
    @select = {}
    @select[:grupos] = ['Algas y protoctistas', 'Anfibios', 'Arácnidos', 'Aves', 'Crustáceos', 'Hongos', 'Insectos', 'Mamíferos', 'Moluscos', 'Otros invertebrados', 'Peces', 'Plantas', 'Reptiles', 'Virus y bacterias']
    @select[:origenes] = ['Criptogénica', 'Exótica', 'Nativa', 'Nativa/Exótica', 'Se desconoce']
    @select[:presencias] = ['Ausente', 'Confinado', 'Indeterminada', 'Por confirmar', 'Presente', 'Se desconoce']
    @select[:instrumentos_legales] = ['Acuerdo enfermedades y plagas SAGARPA 2016', 'Acuerdo especies exóticas SEMARNAT', 'MOD NOM-005-FITO-1995', 'NOM-016-SEMARNAT-2013', 'NOM-043-FITO-1999']
    @select[:ambientes] = ['Dulceacuícola', 'Marino', 'Salobre', 'Terrestre', 'Se desconoce']  # Se necesita estandarizar
    @select[:estatus] = ['Invasora', 'No invasora']
    @select[:fichas] = ['Sí', 'No']
  end

  def opciones_seleccionadas
    @selected = {}
    if params[:nombre_cientifico].present?
      @selected[:nombre_cientifico] = {
        valor: params[:nombre_cientifico],
        nom_campo: 'Nombre cientifico'
      }
    end
    if params[:grupo].present?
      @selected[:grupo] = {}
      @selected[:grupo][:valor] = params[:grupo]
      @selected[:grupo][:nom_campo] = 'Grupo'
    end

    if params[:origen].present?
      @selected[:origen] = {}
      @selected[:origen][:valor] = params[:origen]
      @selected[:origen][:nom_campo] = 'Origen'
    end

    if params[:presencia].present?
      @selected[:presencia] = {}
      @selected[:presencia][:valor] = params[:presencia]
      @selected[:presencia][:nom_campo] = 'Presencia'
    end

    if params[:instrumento].present?
      @selected[:instrumento] = {}
      @selected[:instrumento][:valor] = params[:instrumento]
      @selected[:instrumento][:nom_campo] = 'Regulada por otros instrumentos'
    end

    if params[:ambiente].present?
      @selected[:ambiente] = {}
      @selected[:ambiente][:valor] = params[:ambiente]
      @selected[:ambiente][:nom_campo] = 'Ambiente'
    end

    if params[:estatus].present?
      @selected[:estatus] = {}
      @selected[:estatus][:valor] = params[:estatus]
      @selected[:estatus][:nom_campo] = 'Estatus'
    end

    if params[:ficha].present?
      @selected[:ficha] = {}
      @selected[:ficha][:valor] = params[:ficha]
      @selected[:ficha][:nom_campo] = 'Ficha'
    end
  end

  def condiciones_filtros(row)
    @selected.each do |campo, v|  # Compara que las condiciones se cumplan
      if campo == :nombre_cientifico
        termino = v[:valor].to_s.downcase.strip
        nombre_cientifico = (row['Nombre cientifico'] || row['Nombre científico'] || '').to_s.downcase.strip
        
        next if termino.blank?
        return false unless nombre_cientifico.include?(termino)
        next
      end
      if v[:nom_campo] == 'Ficha'
        if v[:valor] == 'Sí'
          if row[v[:nom_campo]].blank?
            return false
          end
        else
          if row[v[:nom_campo]].present?
            return false
          end
        end

      else
        if row[v[:nom_campo]].blank?  # Si es vacio entonces no coincide
          return false
        end

        val_params = v[:valor].split('/')
        val_excel = row[v[:nom_campo]].gsub('/ ', '/').split('/')
        return false unless (val_params & val_excel).present?
      end
    end  # End @selected.each

    true
  end

end