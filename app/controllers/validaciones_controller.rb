class ValidacionesController < ApplicationController
  # Estas validaciones son los records que provienen desde SQL Server directamente (MS Access), ademas
  # de las validaciones de los archivos en excel, csv o taxones que copien y peguen en la caseta de texto

  # El request sigue siendo inseguro, hasta no poder hacer la conexion con un webservice con WSDL
  # desde SQL Server

  #Quita estos metodos para que pueda cargar correctamente la peticion
  skip_before_filter  :verify_authenticity_token, :set_locale, only: [:update, :insert, :delete]
  before_action :authenticate_request!, only: [:update, :insert, :delete]
  layout false, only: [:update, :insert, :delete]

  def update
    if params[:tabla] == 'especies'
      EspecieBio.delay.actualiza(params[:id], params[:base], params[:tabla])
    else
      Bases.delay.update_en_volcado(params[:id], params[:base], params[:tabla])
    end
    render :text => 'Datos de UPDATE correctos'
  end

  def insert
    if params[:tabla] == 'especies'
      EspecieBio.delay.completa(params[:id], params[:base], params[:tabla])
    else
      Bases.delay.insert_en_volcado(params[:id], params[:base], params[:tabla])
    end
    render :text => 'Datos de INSERT correctos'
  end

  def delete
    Bases.delay.delete_en_volcado(params[:id], params[:base], params[:tabla])
    render :text => 'Datos de DELETE correctos'
  end

  def taxon
  end

  # Validacion de taxones por medio de un csv o a traves de web
  def resultados_taxon_simple
    return @match_taxa= 'Por lo menos debe haber un taxón o un archivo' unless params[:lote].present? || params[:batch].present?

    if params[:lote].present?
      @match_taxa = Hash.new
      params[:lote].split("\r\n").each do |linea|
        e= Especie.where("nombre_cientifico = '#{linea}'")       #linea de SQL Server

        if e.first
          @match_taxa[linea] = e
        else
          ids = FUZZY_NOM_CIEN.find(linea, 3)
          coincidencias = ids.present? ? Especie.where("especies.id IN (#{ids.join(',')})").order('nombre_cientifico ASC') : nil
          @match_taxa[linea] = coincidencias.length > 0 ? coincidencias : 'Sin coincidencia'
        end
      end
    elsif params[:batch].present?
      validaBatch(params[:batch])

    end
    #@match_taxa = @match_taxa ? errores.join(' ') : 'Los datos fueron procesados correctamente'
  end

  # Validacion a traves de un excel .xlsx
  def resultados_taxon_excel
    @errores = []
    uploader = ArchivoUploader.new

    begin
      content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

      if params[:excel].content_type != content_type
        @errores << t('errors.messages.extension_validacion_excel')
      else
        xlsx = Roo::Excelx.new(params[:excel].path, nil, :ignore)
        @sheet = xlsx.sheet(0)  # toma la primera hoja por default

        rows = @sheet.last_row - @sheet.first_row  # Para quietarle del conteo la cabecera
        columns = @sheet.last_column

        @errores << 'La primera hoja de tu excel no tiene información' if rows < 0
        @errores << 'Las columnas no son las mínimas necesarias para poder leer tu excel' if columns < 7

        if @errores.empty?
          cabecera = @sheet.row(1)
          cc = comprueba_columnas(cabecera)

          # Por si no cumple con las columnas obligatorias
          if cc[:faltan].any?
            @errores << "Algunas columnas obligatorias no fueron encontradas en tu excel: #{cc[:faltan].join(', ')}"
          else
            uploader.store!(params[:excel])  # Guarda el archivo
            valida_campos(@sheet, cc[:asociacion])  # Valida los campos en la base
          end
        end
      end  # Fin del tipo de archivo

    rescue CarrierWave::IntegrityError => c
      @errores << c
    end  # Fin del rescue
  end

  private

  def asigna_categorias_correspondientes(taxon)
    return nil unless taxon.ancestry_ascendente_directo.present?  # Por si se les olvido poner el ascendente_directo o es reino
    ids = taxon.ancestry_ascendente_directo.gsub('/',',')

    Especie.select('nombre, nombre_categoria_taxonomica').categoria_taxonomica_join.caso_rango_valores('especies.id',ids).each do |ancestro|
      categoria = 'x_' << I18n.transliterate(ancestro.nombre_categoria_taxonomica).gsub(' ','_').downcase
      next unless Lista::COLUMNAS_CATEGORIAS.include?(categoria)
      eval("taxon.#{categoria} = ancestro.nombre")  # Asigna el nombre del ancestro si es que coincidio con la categoria
    end

    # Asigna la categoria taxonomica
    taxon.x_categoria_taxonomica = taxon.categoria_taxonomica.nombre_categoria_taxonomica
    taxon
  end

  # Si concidio mas de uno, busca recursivamente arriba de genero (familia) para ver el indicado
  def busca_recursivamente(taxones, hash)
    coincidio_alguno = false
    taxon_coincidente = Especie.none
    nombres = hash['nombre_cientifico'].split(' ')
    h = hash

    taxones.each do |t|  # Iterare cada taxon que resulto parecido para ver cual es el correcto
      t = asigna_categorias_correspondientes(t)
      next unless t.present?  # Por si regresa nulo

      # Si es la especie lo mando directo a coincidencia
      cat_tax_taxon_cat = I18n.transliterate(t.x_categoria_taxonomica).gsub(' ','_').downcase
      if cat_tax_taxon_cat == 'especie' && nombres.length == 2 && hash[:infraespecie].blank?
        return {taxon: t, hash: h, estatus: true}
      end

      # Comparamos entonces la familia, si vuelve a coincidir seguro existe un error en catalogos
      if t.x_familia == hash['familia'].downcase

        if coincidio_alguno
          h = h.merge(SCAT_Observaciones: 'Existen 2 taxones iguales, coinciden familias')
          return {hash: h, estatus: false}
        else
          taxon_coincidente = t
          coincidio_alguno = true
        end
      end
    end  #Fin each taxones coincidentes

    # Mando el taxon si coincidio alguno
    if coincidio_alguno
      return {taxon: taxon_coincidente, hash: h, estatus: true}
    else  # De lo contrario no hubo coincidencias claras
      h = h.merge(SCAT_Observaciones: 'Existen 2 taxones iguales, no coinciden familias')
      return {hash: h, estatus: false}
    end
  end

  # Encuentra el mas parecido
  def encuentra_id_por_nombre_cientifico(hash = {})
    # Evita que el nombre cientifico este vacio
    if hash['nombre_cientifico'].blank?
      h = h.merge(SCAT_Observaciones: 'El nombre cientifico está vacío')
      return {hash: h, estatus: false}
    end

    h = hash
    taxon = Especie.where(nombre_cientifico: hash['nombre_cientifico'])

    if taxon.length == 1  # Caso mas sencillo, coincide al 100 y solo es uno
      return {taxon: taxon.first, hash: hash, estatus: true}

    elsif taxon.length > 1  # Encontro el mismo nombre cientifico mas de una vez
      return busca_recursivamente(taxon, hash)

    else
      # Parte de expresiones regulares a ver si encuentra alguna coincidencia
      nombres = hash['nombre_cientifico'].split(' ')

      taxon = if nombres.length == 2  # Especie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} %#{nombres[1]}'")
              elsif nombres.length == 3  # Infraespecie
                Especie.where("nombre_cientifico LIKE '#{nombres[0]} %#{nombres[1]} %#{nombres[2]}'")
              elsif nombres.length == 1 # Genero o superior
                Especie.where("nombre_cientifico LIKE '#{nombres[0]}'")
              end

      if taxon.length == 1  # Caso mas sencillo
        return {taxon: taxon.first, hash: hash, estatus: true}
      elsif taxon.length > 1
        return busca_recursivamente(taxon, hash)
      else  # Lo buscamos con el fuzzy match y despues con el algorithmo de aproximacion
        h = h.merge(SCAT_Observaciones: 'Caso no muy claro')
        return {hash: h, estatus: false}
      end

    end  #Fin de las posibles coincidencias
  end

  def valida_campos(sheet, asociacion)
    @hash = []
    primera_fila = true

    puts asociacion.inspect
    #sheet.parse(:clean => true)  # Para limpiar los caracteres de control y espacios en blanco de mas
    sheet.parse(asociacion).each do |hash|
      if primera_fila
        primera_fila = false
        next
      end

      info = encuentra_id_por_nombre_cientifico(hash)

      if info[:estatus]
        @hash << info[:hash].merge(nombre_cientifico_cat: info[:taxon].nombre_cientifico)
      else
        @hash << info[:hash]
      end
    end
  end

  def comprueba_columnas(cabecera)
    columnas_obligatoraias = %w(familia genero especie autoridad infraespecie categoria nombre_cientifico)
    columnas_opcionales = %w(division subdivision clase subclase orden suborden infraorden superfamilia autoridad_infraespecie)
    columnas_asociadas = Hash.new
    columnas_faltantes = []

    cabecera.each do |c|
      next unless c.present?  # para las cabeceras vacias
      cab = I18n.transliterate(c).gsub(' ','_').gsub('-','_').downcase

      if columnas_obligatoraias.include?(cab) || columnas_opcionales.include?(cab)
        columnas_obligatoraias.delete(cab) if columnas_obligatoraias.include?(cab)

        # Se hace con regexp porque por default agarra las similiares, ej: Familia y Superfamilia (toma la primera)
        columnas_asociadas[cab] = "^#{c}$"
      end
    end

    columnas_obligatoraias.compact.each do |col_obl|
      columnas_faltantes << t("columnas_obligatorias_excel.#{col_obl}")
    end

    {faltan: columnas_faltantes, asociacion: columnas_asociadas}
  end

  def authenticate_request!
    return nil unless CONFIG.ip_sql_server.include?(request.remote_ip)
    return nil unless params[:secret] == CONFIG.secret_sql_server.to_s.parameterize
    return nil if params[:id].blank? || params[:base].blank? || params[:tabla].blank?
    return nil unless CONFIG.bases.include?(params[:base])
    return nil unless Bases::EQUIVALENCIA.include?(params[:tabla])
  end
end