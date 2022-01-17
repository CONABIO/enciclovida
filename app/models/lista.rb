class Lista < ActiveRecord::Base

  self.table_name = "#{CONFIG.bases.ev}.listas"

  attr_accessor :taxones, :taxon, :columnas_array, :hash_especies
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
  COLUMNAS_RIESGO_COMERCIO = %w(x_nom x_iucn x_cites)
  COLUMNAS_CATEGORIAS = CategoriaTaxonomica::CATEGORIAS.map{|cat| "x_#{cat}"}
  COLUMNAS_CATEGORIAS_PRINCIPALES = %w(x_reino x_division x_phylum x_clase x_orden x_familia x_genero x_especie)
  COLUMNAS_FOTOS = %w(x_foto_principal x_naturalista_fotos x_bdi_fotos)
  COLUMNAS_DEFAULT = %w(id nombre_cientifico x_nombre_comun_principal x_nombres_comunes x_categoria_taxonomica
                        x_estatus x_tipo_distribucion
                        cita_nomenclatural nombre_autoridad)
  COLUMNAS_BASICAS = %w(id nombre_cientifico x_categoria_taxonomica x_estatus)                        
  COLUMNAS_GENERALES = COLUMNAS_DEFAULT + COLUMNAS_RIESGO_COMERCIO + COLUMNAS_CATEGORIAS_PRINCIPALES

  # El orden absoluto de las columnas en el excel
  COLUMNAS_ORDEN = %w(nombre_cientifico x_nombres_comunes) + COLUMNAS_CATEGORIAS_PRINCIPALES + COLUMNAS_RIESGO_COMERCIO + %w(x_tipo_distribucion x_ambiente x_num_reg id x_categoria_taxonomica x_estatus x_url_ev x_bibliografia)

  def after_initialize
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
    asigna_columnas_extra  # Para columnas que tienen un grupo de columnas
    xlsx = RubyXL::Workbook.new
    sheet = xlsx[0]
    sheet.sheet_name = 'Resultados'
    fila = 1  # Para no sobreescribir la cabecera
    columna = 0

    # cols = if columnas_array.present?
    #           columnas_array
    #        else
    #           columnas.split(',') if columnas.present?
    #        end

    ordena_columnas
    cols = columnas_array

    # Para la cabecera
    cols.each do |a|
      sheet.add_cell(0,columna,I18n.t("listas_columnas.generales.#{a}", default: I18n.t("listas_columnas.categorias.#{a}", default: a)))
      columna+= 1
    end

    # Elimina las 3 primeras, para que no trate de evaluarlas mas abajo
    cols.slice!(0..2) if opts[:asignar]

    if opts[:es_busqueda]  # Busqueda basica o avanzada
      r = Especie.find_by_sql(opts[:busqueda])
      datos_descarga(r)
    elsif opts[:region]  # Descarga taxa de la busqueda por region
      self.hash_especies = opts[:hash_especies]
      r = Especie.select_basico.left_joins(:categoria_taxonomica, :adicional, :scat).where("#{Scat.attribute_alias(:catalogo_id)} IN (?)", hash_especies.keys).includes(:tipos_distribuciones, :catalogos, :adicional, :nombres_comunes, :bibliografias, :scat)
      datos_descarga(r)
    end

    taxones.each do |taxon|
      if opts[:asignar]
        # Viene del controlador validaciones, taxon contiene, estatus, el taxon y mensaje
        if taxon[:estatus]  # Si es un sinónimo
          if taxon[:taxon_valido].present?
            self.taxon = taxon[:taxon_valido]
          else  # La rewspuesta es el taxon que encontro
            self.taxon = taxon[:taxon]
          end

          nombre_cientifico = self.taxon.nombre_cientifico

        else  # Si tiene muchos taxones como coincidencia
          self.taxon = Especie.none

          if taxon[:taxones].present?  # Cuando coincidio varios taxones no pongo nada
            nombre_cientifico = taxon[:taxones].map{|t| t.nombre_cientifico}.join(', ')
          else
            nombre_cientifico = ''
          end
        end

        asigna_datos
        columna = 3  # Asigna la columna desde el 3, puesto que contiene las sig posiciones antes:

        # El nombre original, el (los) que coincidio, y el mensaje
        sheet.add_cell(fila,0,taxon[:nombre_orig])
        sheet.add_cell(fila,1,nombre_cientifico)
        sheet.add_cell(fila,2,taxon[:msg])

      else  # Cuando viene de una descarga normal de resultados, es decir todos los taxones existen
        self.taxon = taxon
        columna = 0
      end

      cols.each do |a|
        begin
          sheet.add_cell(fila,columna,self.taxon.try(a))
        rescue  # Por si existe algun error en la evaluacion de algun campo
          sheet.add_cell(fila,columna,'¡Hubo un error!')
        end
        columna+= 1
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

  def to_pdf(opts={})
    # Para que parse los paramatros como el controlador de rails
    params = Rack::Utils.parse_nested_query(cadena_especies).symbolize_keys

    br = BusquedaRegion.new
    br.params = params
    br.informacion_descarga_guia

    resp = br.resp
    url_enciclovida = opts[:original_url]
    url_enciclovida.gsub!("/especies.json", "").gsub!("guia=1", "")

    pdf_html = ActionController::Base.new.render_to_string(   
        template: 'busquedas_regiones/guias/especies', 
        layout: 'guias.pdf.erb',
        locals: { resp: resp }, 
    )

    pdf = WickedPdf.new.pdf_from_string(
        pdf_html,
        encoding: 'UTF-8',
        wkhtmltopdf: CONFIG.wkhtmltopdf_path,
        page_size: 'Letter',
        page_height: 279,
        page_width:  215,
        orientation: 'Portrait',
        disposition: 'attachment',
        disable_internal_links: false,
        disable_external_links: false,     
        header: {
            content: ActionController::Base.new.render_to_string(
                'busquedas_regiones/guias/header',
                layout: 'guias.pdf.erb',
                locals: { titulo_guia: resp[:titulo_guia] },
            ),
        },    
        footer: {
            content: ActionController::Base.new.render_to_string(
                'busquedas_regiones/guias/footer',
                layout: 'guias.pdf.erb',
                locals: { url_enciclovida: url_enciclovida },
            ),
        },    
    )

    ruta_dir = Rails.root.join('public','descargas_guias', opts[:fecha])
    FileUtils.mkpath(ruta_dir, :mode => 0755) unless File.exists?(ruta_dir)
    ruta_pdf = ruta_dir.join("#{nombre_lista}.pdf")

    File.open(ruta_pdf, 'wb') do |file|
      file << pdf
    end
  
    # Verifica que el PDF exista
    if File.exists? ruta_pdf
      pdf_url = "#{CONFIG.site_url}descargas_guias/#{opts[:fecha]}/#{nombre_lista}.pdf"

      if params[:correo].present?
        EnviaCorreo.descargar_guia(pdf_url, params[:correo], url_enciclovida).deliver
      end

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
  def datos_descarga(taxa)
    return unless taxa.any?
    self.taxones = []

    taxa.each do |taxon|
      self.taxon = taxon
      asigna_datos
      self.taxones << taxon
    end
  end

  # Metodoq ue comparten las listas y para exportar en excel
  def asigna_datos
    return unless taxon.present?

    cols = if columnas_array.present?
      columnas_array
    else
      columnas.split(',') if columnas.present?
    end

    cols.each do |col|

      case col
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
        self.taxon.x_categoria_taxonomica = taxon.try(:nombre_categoria_taxonomica) || taxon.categoria_taxonomica.nombre_categoria_taxonomica
      when 'x_estatus'
        self.taxon.x_estatus = Especie::ESTATUS_SIGNIFICADO[taxon.estatus]
      when 'x_nombres_comunes'
        nombres_comunes = taxon.nombres_comunes.map{ |nom| nom.nombre_comun.capitalize }.uniq.sort
        next unless nombres_comunes.any?
        self.taxon.x_nombres_comunes = nombres_comunes.join(', ')
      when 'x_tipo_distribucion'
        tipos_distribuciones = taxon.tipos_distribuciones.map(&:descripcion).uniq
        next unless tipos_distribuciones.any?
        self.taxon.x_tipo_distribucion = tipos_distribuciones.join(',')
      when 'x_nom'  # TODO: homologar las demas descargas
        if hash_especies.present?  # Quiere decir que viene de las descargas pr region
          nom = []
          taxon.catalogos.each do |catalogo|
            if catalogo.nivel1 == 4 && catalogo.nivel2 == 1
              nom << catalogo
            end
          end
        else
          nom = taxon.catalogos.nom.distinct
        end

        next unless nom.any?
        self.taxon.x_nom = nom.map(&:descripcion).join(', ')
      when 'x_iucn'  # TODO: homologar las demas descargas
        if hash_especies.present?  # Quiere decir que viene de las descargas pr region
          iucn = []
          taxon.catalogos.each do |catalogo|
            if catalogo.nivel1 == 4 && catalogo.nivel2 == 2
              iucn << catalogo
            end
          end
        else
          iucn = taxon.catalogos.iucn.distinct
        end

        next unless iucn.any?
        self.taxon.x_iucn = iucn.map(&:descripcion).join(', ')
      when 'x_cites'  # TODO: homologar las demas descargas
        if hash_especies.present?  # Quiere decir que viene de las descargas pr region
          cites = []
          taxon.catalogos.each do |catalogo|
            if catalogo.nivel1 == 4 && catalogo.nivel2 == 3
              cites << catalogo
            end
          end
        else
          cites = taxon.catalogos.cites.distinct
        end

        next unless cites.any?
        self.taxon.x_cites = cites.map(&:descripcion).join(', ')        
      when 'x_ambiente'  # TODO: homologar las demas descargas
        if hash_especies.present?  # Quiere decir que viene de las descargas pr region
          ambiente = []
          taxon.catalogos.each do |catalogo|
            if catalogo.nivel1 == 2
              ambiente << catalogo
            end
          end
        else
          ambiente = taxon.catalogos.ambientes
        end

        next unless ambiente.any?
        self.taxon.x_ambiente = ambiente.map(&:descripcion).join(', ')        
      when 'x_naturalista_fotos'
        next unless adicional = taxon.adicional
        if proveedor = taxon.proveedor
          self.taxon.x_naturalista_fotos = "#{CONFIG.site_url}especies/#{taxon.id}/fotos-naturalista" if proveedor.naturalista_id.present? && adicional.foto_principal.present?
        end
      when 'x_bdi_fotos'
        next unless adicional = taxon.adicional
        self.taxon.x_bdi_fotos = "#{CONFIG.site_url}especies/#{taxon.id}/bdi-photos" if adicional.foto_principal.present?
      when 'x_bibliografia'
        biblio = taxon.bibliografias
        self.taxon.x_bibliografia = biblio.map(&:cita_completa).join("\n")
      when 'x_url_ev'
        self.taxon.x_url_ev = "#{CONFIG.site_url}especies/#{taxon.id}-#{taxon.nombre_cientifico.estandariza}"
      when 'x_num_reg'
        self.taxon.x_num_reg = hash_especies[taxon.scat.catalogo_id]
      else
        next
      end  # End switch
    end  # End each cols

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
    
    if columnas_array.include?('x_taxa_sup')
      self.columnas_array = columnas_array << COLUMNAS_CATEGORIAS_PRINCIPALES
      self.columnas_array.delete('x_taxa_sup')
    end
    
    if columnas_array.include?('x_col_basicas')
      self.columnas_array = columnas_array << COLUMNAS_BASICAS
      self.columnas_array.delete('x_col_basicas')
    end

    self.columnas_array = columnas_array.flatten
    self.columnas = columnas_array.join(',')
  end

  def ordena_columnas
    cols = if columnas_array.present?
              columnas_array
            else
              columnas.split(',') if columnas.present?
            end 
            
    self.columnas_array = COLUMNAS_ORDEN & cols
  end

end
