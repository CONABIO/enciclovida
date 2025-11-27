class Lista < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.listas"

  attr_accessor :taxones, :taxones_query, :taxones_query_orig, :taxon, :columnas_array, :hash_especies, :ancestros_hash
  attr_accessor :tabla_catalogos, :taxa_superior  # Es un booleano para saber si ya hizo el query al menos una vez
  attr_accessor :es_busqueda, :region, :validacion
  validates :nombre_lista, :presence => true, :uniqueness => true
  before_update :quita_repetidos

  #validates :formato, :presence => true

  ESTATUS_LISTA = [
      [0, 'No'],
      [1, 'Sí']
  ]

  FORMATOS = [
      [1, '.csv'],
      [2, '.xlsx'],
      [3, '.txt']
  ]

  FORMATOS_DESCARGA = %w(csv xlsx txt)

  # Columnas permitidas a exportar por el usuario
  COLUMNAS_PROVEEDORES = %w(catalogo_id x_naturalista_id x_snib_id x_snib_reino)
  COLUMNAS_GEODATOS = %w(x_naturalista_obs x_snib_registros x_geoportal_mapa)
  COLUMNAS_RIESGO_COMERCIO = %w(x_nom x_nom_obs x_iucn x_iucn_obs x_cites x_cites_obs)
  #COLUMNAS_RIESGO_COMERCIO = %w(x_nom x_nom_obs)
  COLUMNAS_CATEGORIAS = CategoriaTaxonomica::CATEGORIAS.map{|cat| "x_#{cat}"}
  COLUMNAS_CATEGORIAS_PRINCIPALES = %w(x_reino x_division x_phylum x_clase x_orden x_familia x_genero x_especie)
  COLUMNAS_FOTOS = %w(x_foto_principal x_naturalista_fotos x_bdi_fotos)
  COLUMNAS_DEFAULT = %w(id nombre_cientifico x_nombre_comun_principal x_nombres_comunes x_categoria_taxonomica
                        x_estatus x_tipo_distribucion
                        cita_nomenclatural nombre_autoridad)
  COLUMNAS_BASICAS = %w(x_idcat id nombre_cientifico x_categoria_taxonomica x_estatus x_nombre_comun_principal x_foto_principal x_url_ev)                        
  COLUMNAS_GENERALES = COLUMNAS_DEFAULT + COLUMNAS_RIESGO_COMERCIO + COLUMNAS_CATEGORIAS_PRINCIPALES

  #columnas de prioritarias
  COLUMNAS_CONSERVACION = %w(x_prioritaria x_prioritaria_conabio x_observacion_prioritarias)

  # El orden absoluto de las columnas en el excel
  COLUMNAS_ORDEN = %w(nombre_cientifico x_nombres_comunes x_categoria_taxonomica x_estatus x_tipo_distribucion x_usos x_ambiente x_num_reg x_nombre_comun_principal x_foto_principal) + COLUMNAS_RIESGO_COMERCIO  + COLUMNAS_CATEGORIAS_PRINCIPALES + %w(x_bibliografia x_url_ev id x_idcat)+ COLUMNAS_CONSERVACION

  def after_initialize(opts)
    self.taxones = []
    self.columnas_array = []
  end

  # Crea el csv con los datos
  def to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << nombres_columnas
      datos # Completa los datos de los taxones por medio del ID

      taxones.each do |taxon|
        datos_taxon = []

        columnas.split(',').each do |col|
          datos_taxon << eval("taxon.#{col}")
        end
        csv << datos_taxon
      end
    end
  end

  # Para crear el excel con los datos
  def to_excel(opts={})
    self.es_busqueda = opts[:es_busqueda]
    self.region = opts[:region]
    self.validacion = opts[:validacion]

    asigna_columnas_extra  # Para columnas que tienen un grupo de columnas
    xlsx = RubyXL::Workbook.new
    sheet = xlsx[0]
    sheet.sheet_name = 'Resultados'
    fila = 1  # Para no sobreescribir la cabecera
    columna = 0

    ordena_columnas(opts)
    cols = columnas_array

    # Para la cabecera
    cols.each do |a|
      sheet.add_cell(0,columna,I18n.t("listas_columnas.generales.#{a}", default: I18n.t("listas_columnas.categorias.#{a}", default: a)))
      columna+= 1
    end

    # Elimina las 3 primeras, para que no trate de evaluarlas mas abajo
    cols.slice!(0..2) if validacion

    if es_busqueda  # Busqueda basica o avanzada
      self.taxones_query_orig = Especie.find_by_sql(opts[:busqueda])
      datos_descarga
    elsif region  # Descarga taxa de la busqueda por region
      self.hash_especies = opts[:hash_especies]
      self.taxones_query_orig = Especie.select(:id, :ancestry_ascendente_obligatorio).joins(:scat, :categoria_taxonomica).where("IDCAT IN (?)", hash_especies.keys)
      datos_descarga
    end

    taxones.each do |t|
      if validacion
        # Viene del controlador validaciones, taxon contiene, estatus, el taxon y mensaje
        if t[:estatus]  # Si es un sinónimo
          if t[:taxon_valido].present?
            self.taxon = t[:taxon_valido]
          else  # La respuesta es el taxon que encontro
            self.taxon = t[:taxon]
          end

          nombre_cientifico = self.taxon.nombre_cientifico

        else  # Si tiene muchos taxones como coincidencia
          self.taxon = Especie.none

          if t[:taxones].present?  # Cuando coincidio varios taxones no pongo nada
            nombre_cientifico = t[:taxones].map{|tax| tax.nombre_cientifico}.join(', ')
          else
            nombre_cientifico = ''
          end
        end
        
        asigna_datos
        columna = 3  # Asigna la columna desde el 3, puesto que contiene las sig posiciones antes:

        # El nombre original, el (los) que coincidio, y el mensaje
        sheet.add_cell(fila,0,t[:nombre_orig])
        sheet.add_cell(fila,1,nombre_cientifico)
        sheet.add_cell(fila,2,t[:msg])

        cols.each do |a|
          begin
            sheet.add_cell(fila,columna,taxon.try(a))
          rescue  # Por si existe algun error en la evaluacion de algun campo
            sheet.add_cell(fila,columna,'¡Hubo un error!')
          end
          columna+= 1
        end

      else  # Cuando viene de una descarga normal de resultados, es decir todos los taxones existen
        columna = 0

        cols.each do |a|
          begin
            sheet.add_cell(fila,columna,t.try(a))
          rescue  # Por si existe algun error en la evaluacion de algun campo
            sheet.add_cell(fila,columna,'¡Hubo un error!')
          end
          columna+= 1
        end        
      end

      fila+= 1
    end

    # Escribe el excel en cierta ruta
    fecha = Time.now.strftime("%Y-%m-%d")
    ruta_dir = Rails.root.join('public','descargas_resultados', fecha)
    nombre_archivo = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + '_taxa_EncicloVida.xlsx'
    FileUtils.mkpath(ruta_dir, :mode => 0755) unless File.exists?(ruta_dir)
    ruta_excel = ruta_dir.join(nombre_archivo)
    xlsx.write(ruta_excel)

    if File.exists? ruta_excel
      excel_url = "#{CONFIG.site_url}descargas_resultados/#{fecha}/#{nombre_archivo}"

      if opts[:correo].present?
        EnviaCorreo.descargar_taxa(excel_url, opts[:correo], opts[:original_url]).deliver
      end

      {estatus: true, excel_url: excel_url}
    else
      {estatus: true, msg: 'No pudo guardar el archivo'}
    end

  end

  def to_pdf(opts = {})
  # Para que parse los parámetros como el controlador de Rails
  params = Rack::Utils.parse_nested_query(cadena_especies, "?&").symbolize_keys

  br = BusquedaRegion.new
  br.params = params
  br.informacion_descarga_guia

  resp = br.resp
  url_enciclovida = opts[:original_url]
  url_enciclovida.gsub!("/especies.json", "").gsub!("guia=1", "")

  # Crear una sola instancia de ActionController::Base
  controller = ActionController::Base.new

  # Renderizar contenido HTML del PDF
  pdf_html = controller.render_to_string(
    template: 'busquedas_regiones/guias/especies',
    layout: 'guias.pdf.erb',
    locals: { resp: resp }
  )

  # Generar el PDF
  pdf = WickedPdf.new.pdf_from_string(
    pdf_html,
    encoding: 'UTF-8',
    wkhtmltopdf: CONFIG.wkhtmltopdf_path,
    page_size: 'Letter',
    page_height: 279,
    page_width: 215,
    orientation: 'Portrait',
    disposition: 'attachment',
    disable_internal_links: false,
    disable_external_links: false,
    header: {
      content: controller.render_to_string(
        'busquedas_regiones/guias/header',
        layout: 'guias.pdf.erb',
        locals: { titulo_guia: resp[:titulo_guia] }
      )
    },
    footer: {
      content: controller.render_to_string(
        'busquedas_regiones/guias/footer',
        layout: 'guias.pdf.erb',
        locals: { url_enciclovida: url_enciclovida }
      )
    }
  )

  # Guardar el PDF en el servidor
  ruta_dir = Rails.root.join('public', 'descargas_guias', opts[:fecha])
  FileUtils.mkpath(ruta_dir, mode: 0o755) unless File.exist?(ruta_dir)
  ruta_pdf = ruta_dir.join("#{nombre_lista}.pdf")

  File.open(ruta_pdf, 'wb') { |file| file << pdf }

  # Verifica que el PDF exista
  if File.exist?(ruta_pdf)
    pdf_url = "#{CONFIG.site_url}descargas_guias/#{opts[:fecha]}/#{nombre_lista}.pdf"

    EnviaCorreo.descargar_guia(pdf_url, params[:correo], url_enciclovida).deliver if params[:correo].present?

    { estatus: true, pdf_url: pdf_url }
  else
    { estatus: false, msg: 'No pudo guardar el archivo' }
  end
end

  # Para asignar los datos de una lista de ids de especies, hacia un excel o csv, el recurso puede ser un string o un objeto
  def datos(opc={})
    return [] unless cadena_especies.present?

    # Por default muestra todos
    Especie.caso_rango_valores('especies.id',cadena_especies).order('nombre_cientifico ASC').limit(opc[:limit] ||= 300000).each do |taxon|
      self.taxon = taxon
      asigna_datos
      self.taxones << taxon
    end
  end

  # Para asignar los datos de una consulta de resultados, hacia un excel o csv, el recurso puede ser un string o un objeto
  def datos_descarga
    return unless taxones_query_orig.any?
    ids = taxones_query_orig.map(&:id)
    self.taxones_query = Especie.where(id: ids)

    self.taxones = []
    arma_taxones_query

    taxones_query.each do |t|
      self.taxon = t
      asigna_datos
      self.taxones << taxon
    end
  end

  # Metodo que arma el query con puros includes para una mayor rapidez en la descarga
  def arma_taxones_query
    cols = if columnas_array.present?
      columnas_array
    else
      columnas.split(',') if columnas.present?
    end

    cols.each do |col|

      case col
      when 'x_idcat'
        self.taxones_query = taxones_query.includes(:scat)    
      when 'x_snib_id'
        if proveedor = taxon.proveedor
          self.taxon.x_snib_id = proveedor.snib_id
        end
      when 'x_snib_reino'
        if proveedor = taxon.proveedor
          self.taxon.x_snib_reino = proveedor.snib_reino
        end
      when 'x_naturalista_id'
        if proveedor = taxon.proveedor
          self.taxon.x_naturalista_id = proveedor.naturalista_id
        end
      when 'x_nombre_comun_principal', 'x_foto_principal', 'x_naturalista_fotos', 'x_bdi_fotos'
        self.taxones_query = taxones_query.includes(:adicional)
      when 'x_categoria_taxonomica'
        self.taxones_query = taxones_query.includes(:categoria_taxonomica)
      when 'x_nombres_comunes'
        self.taxones_query = taxones_query.includes(:nombres_comunes)
      when 'x_tipo_distribucion'
        self.taxones_query = taxones_query.includes(:tipos_distribuciones)
      when 'x_nom', 'x_iucn', 'x_cites', 'x_ambiente', 'x_usos'  # Esto es una lindura!
        self.taxones_query = taxones_query.includes(:catalogos)      
      when 'x_bibliografia'
        self.taxones_query = taxones_query.includes(:bibliografias) 
      when 'x_num_reg'
        self.taxones_query = taxones_query.includes(:scat) 
      when 'x_reino', 'x_division', 'x_phylum', 'x_clase', 'x_orden', 'x_familia', 'x_genero', 'x_especie'
        next if ancestros_hash.present?  # Para ya no volver a entrar

        # Linea de la muerte!, saca todos los ancestros obligatorios de todos los taxones coincidentes, sin repetir y sin ser el mismo id que su ancestry (asi esta en la base). Y sin consultar a la base aun
        ancestros_ids = taxones_query_orig.map{|r| r.ancestry_ascendente_obligatorio.split(",").reject{|c| c.empty? } }.flatten.uniq
        self.ancestros_hash = {}  # Para acceder como hash de una forma sencilla
        ancestros = Especie.includes(:categoria_taxonomica).where(id: ancestros_ids)

        ancestros.each do |ancestro|
          self.ancestros_hash[ancestro.id] = { nombre_cientifico: ancestro.nombre_cientifico, categoria: ancestro.categoria_taxonomica.nombre_categoria_taxonomica }
        end  
      else
        next
      end  # End switch
    end  # End each cols

  end

  # Metodo que comparten las listas y para exportar en excel
  def asigna_datos
    return unless taxon.present?
    self.tabla_catalogos = false
    self.taxa_superior = false

    cols = if columnas_array.present?
      columnas_array
    else
      columnas.split(',') if columnas.present?
    end

    cols.each do |col|

      case col
      when 'x_idcat'
        self.taxon.x_idcat = taxon.scat.catalogo_id
      when 'x_snib_id'
        if proveedor = taxon.proveedor
          self.taxon.x_snib_id = proveedor.snib_id
        end
      when 'x_snib_reino'
        if proveedor = taxon.proveedor
          self.taxon.x_snib_reino = proveedor.snib_reino
        end
      when 'x_naturalista_id'
        if proveedor = taxon.proveedor
          self.taxon.x_naturalista_id = proveedor.naturalista_id
        end
      when 'x_foto_principal'
        if adicional = taxon.adicional
          self.taxon.x_foto_principal = adicional.foto_principal
        end
      when 'x_nombre_comun_principal'
        if adicional = taxon.adicional
          self.taxon.x_nombre_comun_principal = adicional.nombre_comun_principal
        end
      when 'x_categoria_taxonomica'
        self.taxon.x_categoria_taxonomica = taxon.categoria_taxonomica.nombre_categoria_taxonomica
      when 'x_estatus'
        self.taxon.x_estatus = Especie::ESTATUS_SIGNIFICADO[taxon.estatus]
      when 'x_nombres_comunes'
        nombres_comunes = taxon.nombres_comunes.map{ |nom| "#{nom.nombre_comun.capitalize} (#{nom.lengua})" }.uniq.sort
        next unless nombres_comunes.any?
        self.taxon.x_nombres_comunes = nombres_comunes.join(', ')
      when 'x_tipo_distribucion'
        tipos_distribuciones = taxon.tipos_distribuciones.map(&:descripcion).uniq
        next unless tipos_distribuciones.any?
        self.taxon.x_tipo_distribucion = tipos_distribuciones.join(',')
      when 'x_prioritaria', 'x_prioritaria_conabio',  'x_observacion_prioritarias'
        next if tabla_catalogos  # Ya no entra una segunda vez
        
        prioritaria, prioritaria_conabio, observacion_prioritarias =  [], [],[]
        catalogos_existe = false

        taxon.catalogos.each do |cat|
          next unless cat.es_catalogo_permitido?

          if cat.es_prioritaria?
            prioritaria << cat.descripcion
            catalogos_existe = true 
            next
          end

          if cat.es_prioritaria_conabio?
            prioritaria_conabio << cat.descripcion  
            catalogos_existe = true 
            next
          end

          
        end

         # AGREGAR ESTA PARTE PARA LAS OBSERVACIONES DE PRIORITARIAS
        taxon.especies_catalogos.each do |cat|
          next if cat.observaciones.blank?
          
          # Para observaciones de prioritarias DOF (nivel2 = 4)
          if [44,45,46,47,48].include?(cat.catalogo_id)  # IDs de catalogos prioritarios DOF
            observacion_prioritarias << cat.observaciones
            catalogos_existe = true
          end
          
          # Para observaciones de prioritarias CONABIO (nivel2 = 5)  
          if [49,50,51,52,53].include?(cat.catalogo_id)  # IDs de catalogos prioritarios CONABIO
            observacion_prioritarias << cat.observaciones
            catalogos_existe = true
          end
        end
        
        next unless catalogos_existe
        self.taxon.x_prioritaria = prioritaria.join(', ') if prioritaria.any?
        self.taxon.x_prioritaria_conabio = prioritaria_conabio.join(', ') if prioritaria_conabio.any?
        self.taxon.x_observacion_prioritarias = observacion_prioritarias.join(', ') if observacion_prioritarias.any?

      when 'x_nom', 'x_iucn', 'x_cites', 'x_ambiente', 'x_usos'
        next if tabla_catalogos  # Ya no entra una segunda vez

        # Se hace en una sola iteracion para evitar duplicar
        nom, iucn, cites, ambiente, usos = [], [], [], [], []
        catalogos_existe = false

        # Para los valores
        taxon.catalogos.each do |cat|
          # Para no iterar lo que no se va a desplegar
          next unless cat.es_catalogo_permitido?

          if cat.es_nom?
            nom << cat.descripcion
            catalogos_existe = true 
            next
          end

          if cat.es_iucn?
            iucn << cat.descripcion
            catalogos_existe = true 
            next
          end
          
          if cat.es_cites?
            cites << cat.descripcion
            catalogos_existe = true 
            next
          end

          if cat.es_ambiente?
            ambiente << cat.descripcion
            catalogos_existe = true 
            next
          end    
          
          if cat.es_usos?
            usos << cat.descripcion
            catalogos_existe = true 
            next
          end          
        end
        
        next unless catalogos_existe  # Si no tiene nada en catalogos no conviene continuar
        self.taxon.x_nom = nom.join(', ') if nom.any?
        self.taxon.x_iucn = iucn.join(', ') if iucn.any?
        self.taxon.x_cites = cites.join(', ') if cites.any?
        self.taxon.x_ambiente = ambiente.join(', ') if ambiente.any?
        self.taxon.x_usos = usos.join(', ') if usos.any?
        
        #  Para las observaciones
        obs_nom, obs_iucn, obs_cites = [], [], []

        taxon.especies_catalogos.each do |cat|
          next if cat.observaciones.blank?

          obs_nom << cat.observaciones if [14,15,16,17].include?(cat.catalogo_id)
          obs_iucn << cat.observaciones if [25,26,27,28,29,30,31,32,1022,1023].include?(cat.catalogo_id)
          obs_cites << cat.observaciones if [22,23,24].include?(cat.catalogo_id)
        end
        
        self.taxon.x_nom_obs = obs_nom.join(', ') if obs_nom.any?
        self.taxon.x_iucn_obs = obs_iucn.join(', ') if obs_iucn.any?
        self.taxon.x_cites_obs = obs_cites.join(', ') if obs_cites.any?

        # Para que proximas interacciones del switch ya no entren
        self.tabla_catalogos = true  
      when 'x_naturalista_fotos'
        next unless adicional = taxon.adicional
        if proveedor = taxon.proveedor
          self.taxon.x_naturalista_fotos = "#{CONFIG.site_url}especies/#{taxon.id}/fotos-naturalista" if proveedor.naturalista_id.present? && adicional.foto_principal.present?
        end
      when 'x_bdi_fotos'
        next unless adicional = taxon.adicional
        self.taxon.x_bdi_fotos = "#{CONFIG.site_url}especies/#{taxon.id}/bdi-photos" if adicional.foto_principal.present?
      when 'x_bibliografia'
        bibliografias = taxon.bibliografias
        self.taxon.x_bibliografia = bibliografias.map(&:cita_completa).join("\n")
      when 'x_url_ev'
        self.taxon.x_url_ev = "#{CONFIG.site_url}especies/#{taxon.id}-#{taxon.nombre_cientifico.estandariza}"
      when 'x_num_reg'
        self.taxon.x_num_reg = hash_especies[taxon.scat.catalogo_id]
      when 'x_reino', 'x_division', 'x_phylum', 'x_clase', 'x_orden', 'x_familia', 'x_genero', 'x_especie'
        next if taxa_superior

        if validacion
          # Para agregar todas las categorias taxonomicas que pidio, primero se intersectan
            cats = COLUMNAS_CATEGORIAS & cols

            if cats.any?
              return if taxon.is_root?  # No hay categorias que completar
              ids = taxon.path_ids

              Especie.select(:nombre, "#{CategoriaTaxonomica.attribute_alias(:nombre_categoria_taxonomica)} AS nombre_categoria_taxonomica").left_joins(:categoria_taxonomica).where(id: ids).each do |ancestro|
                categoria = 'x_' << ancestro.nombre_categoria_taxonomica.estandariza
                next unless COLUMNAS_CATEGORIAS.include?(categoria)
                eval("self.taxon.#{categoria} = ancestro.nombre")  # Asigna el nombre del ancestro si es que coincidio con la categoria
              end
            end          
        else
          next if taxon.is_root?
          ancestros = taxon.path_ids
          next if ancestros.empty?  # Es un root
  
          ancestros.each do |ancestro|
            begin
              x_categoria = 'x_' << ancestros_hash[ancestro][:categoria].estandariza
              # Asigna la categoria taxonomica de acuerdo al ancestro
              eval("self.taxon.#{x_categoria} = \"#{ancestros_hash[ancestro][:nombre_cientifico]}\"")  
            rescue
              next
            end
          end
        end
        
        self.taxa_superior = true
      else
        next
      end  # End switch
    end  # End each cols
  end

  def nombres_columnas(web = false)
    cabecera = []
    columnas.split(',').each do |col|
      cabecera << I18n.t("listas_columnas.generales.#{col}", default: I18n.t("listas_columnas.categorias.#{col}"))
    end
    web ? cabecera.join(',') : cabecera
  end

  private

  def quita_repetidos
    self.cadena_especies = cadena_especies.split(',').compact.uniq.join(',') if cadena_especies.present?
  end

  def asigna_columnas_extra
    return unless columnas.present? || columnas_array.present?

    if columnas_array.blank? && columnas.present?
      self.columnas_array = columnas.split(',')
    end

    if columnas_array.include?('x_cat_riesgo')
      self.columnas_array = columnas_array << COLUMNAS_RIESGO_COMERCIO
      self.columnas_array.delete('x_cat_riesgo')
    end

    if columnas_array.include?('x_conservación')
      self.columnas_array = columnas_array << COLUMNAS_CONSERVACION
      self.columnas_array.delete('x_conservación')
    end
    
    if columnas_array.include?('x_taxa_sup')
      self.columnas_array = columnas_array << COLUMNAS_CATEGORIAS_PRINCIPALES
      self.columnas_array.delete('x_taxa_sup')
    end
    
    if columnas_array.include?('x_col_basicas')
      self.columnas_array = columnas_array << COLUMNAS_BASICAS
      self.columnas_array.delete('x_col_basicas')

      if region
        self.columnas_array << 'x_num_reg'
      end
    end

    self.columnas_array = columnas_array.flatten
    self.columnas = columnas_array.join(',')
  end

  def ordena_columnas(opts={})
    cols = if columnas_array.present?
              columnas_array
            else
              columnas.split(',') if columnas.present?
            end 

    if !validacion
      self.columnas_array = COLUMNAS_ORDEN & cols
    end
  end

end
