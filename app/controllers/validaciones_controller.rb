class ValidacionesController < ApplicationController
  # Estas validaciones son los records que provienen desde SQL Server directamente (MS Access), ademas
  # de las validaciones de los archivos en excel, csv o taxones que copien y peguen en la caseta de texto

  # El request sigue siendo inseguro, hasta no poder hacer la conexion con un webservice con WSDL
  # desde SQL Server

  #Quita estos metodos para que pueda cargar correctamente la peticion
  skip_before_filter  :verify_authenticity_token, :set_locale, only: [:update, :insert, :delete]
  before_action :authenticate_request!, only: [:update, :insert, :delete]
  before_action :authenticate_usuario!, :only => [:taxon, :resultados_taxon_simple, :resultados_taxon_excel]
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
      @errores = []

      if !Validacion::FORMATOS_PERMITIDOS_BATCH.include? params[:batch].content_type
        @errores << 'Lo sentimos, el formato ' + params[:batch].content_type + ' no esta permitido'
      end

      if @errores.empty?
        validacion = Validacion.new(usuario_id: current_usuario.id, nombre_archivo: "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{params[:batch].original_filename.gsub('.csv','')}")
        validacion.delay(priority: NOTIFICATION_PRIORITY).valida_batch(params[:batch].path) if validacion.save
      end
    end
  end

  # Validacion a traves de un excel .xlsx
  def resultados_taxon_excel
    @errores = []
    #uploader = ArchivoUploader.new

    begin
      content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

      if params[:excel].content_type != content_type
        @errores << t('errors.messages.extension_validacion_excel')
      else

        xlsx = Roo::Excelx.new(params[:excel].path, nil, :ignore)
        sheet = xlsx.sheet(0)  # toma la primera hoja por default

        rows = sheet.last_row - sheet.first_row  # Para quietarle del conteo la cabecera
        columns = sheet.last_column

        @errores << 'La primera hoja de tu excel no tiene información' if rows < 0
        @errores << 'Las columnas no son las mínimas necesarias para poder leer tu excel' if columns < 7

        if @errores.empty?
          cabecera = sheet.row(1)
          cc = comprueba_columnas(cabecera)

          # Por si no cumple con las columnas obligatorias
          if cc[:faltan].any?
            @errores << "Algunas columnas obligatorias no fueron encontradas en tu excel: #{cc[:faltan].join(', ')}"
          else
            #uploader.store!(params[:excel])  # Guarda el archivo
            nombre_archivo = "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{params[:excel].original_filename}"
            validacion = Validacion.new(usuario_id: current_usuario.id, nombre_archivo: nombre_archivo.gsub('.xlsx',''))

            # Gurdando el archivo
            path = Rails.root.join('public', 'validaciones_excel', current_usuario.id.to_s, "tmp_#{nombre_archivo}")
            File.open(path, 'wb') do |file|
              file.write(params[:excel].read)
            end

            validacion.delay(priority: NOTIFICATION_PRIORITY).valida_campos(path.to_s, cc[:asociacion]) if validacion.save
          end
        end
      end  # Fin del tipo de archivo

    rescue CarrierWave::IntegrityError => c
      @errores << c
    end  # Fin del rescue
  end


  private


  def authenticate_request!
    return nil unless CONFIG.ip_sql_server.include?(request.remote_ip)
    return nil unless params[:secret] == CONFIG.secret_sql_server.to_s.parameterize
    return nil if params[:id].blank? || params[:base].blank? || params[:tabla].blank?
    return nil unless CONFIG.bases.include?(params[:base])
    return nil unless Bases::EQUIVALENCIA.include?(params[:tabla])
  end

  def comprueba_columnas(cabecera)
    # Se hace un clon para poder borrarlas del array
    columnas_obligatoraias = Validacion::COLUMNAS_OBLIGATORIAS.clone
    columnas_asociadas = Hash.new
    columnas_faltantes = []

    cabecera.each do |c|
      next unless c.present?  # para las cabeceras vacias
      cab = I18n.transliterate(c).gsub(' ','_').gsub('-','_').downcase

      if columnas_obligatoraias.include?(cab) || Validacion::COLUMNAS_OPCIONALES.include?(cab)
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
end