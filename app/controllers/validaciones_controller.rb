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
        nombre_archivo = "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{params[:batch].original_filename}"
        validacion = Validacion.new(usuario_id: current_usuario.id, nombre_archivo: "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{params[:batch].original_filename.gsub('.csv','')}")

        # Creando la carpeta del usuario y gurdando el archivo
        ruta_batch = Rails.root.join('public','validaciones_excel', current_usuario.id.to_s)
        FileUtils.mkpath(ruta_batch, :mode => 0755) unless File.exists?(ruta_batch)

        path = Rails.root.join('public', 'validaciones_excel', current_usuario.id.to_s, "tmp_#{nombre_archivo}")
        File.open(path, 'wb') do |file|
          file.write(params[:batch].read)
        end

        if validacion.save
          if Rails.env.production?
            validacion.delay(queue: 'validaciones').valida_batch(path)
          end
            validacion.valida_batch(path)
        end

      end
    end
  end

  # Validacion a traves de un excel .xlsx
  def resultados_taxon_excel
    @errores = []
    content_type = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'

    if params[:excel].content_type != content_type
      @errores << t('errors.messages.extension_validacion_excel')
    else
      nombre_archivo = "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{params[:excel].original_filename}"
      validacion = Validacion.new(usuario_id: current_usuario.id, nombre_archivo: nombre_archivo.gsub('.xlsx',''))

      # Creando la carpeta del usuario y gurdando el archivo
      ruta_excel = Rails.root.join('public','validaciones_excel', current_usuario.id.to_s)
      FileUtils.mkpath(ruta_excel, :mode => 0755) unless File.exists?(ruta_excel)

      path = Rails.root.join('public', 'validaciones_excel', current_usuario.id.to_s, "tmp_#{nombre_archivo}")
      File.open(path, 'wb') do |file|
        file.write(params[:excel].read)  # Hace una copia del excel, para dejar las columnas originales
      end

      if !File.exists?(path)
        @errores << 'El archivo tiene una inconsistencia'
      else
        xlsx = Roo::Excelx.new(path.to_s)
        sheet = xlsx.sheet(0)  # toma la primera hoja por default

        rows = sheet.last_row - sheet.first_row  # Para quitarle del conteo la cabecera
        columns = sheet.last_column

        @errores << 'La primera hoja de tu excel no tiene información' if rows < 0
        @errores << 'Las columnas no son las mínimas necesarias para poder leer tu excel' if columns < 7
      end

      if @errores.empty?
        cabecera = sheet.row(1)
        cc = comprueba_columnas(cabecera)

        # Por si no cumple con las columnas obligatorias
        if cc[:faltan].any?
          @errores << "Algunas columnas obligatorias no fueron encontradas en tu excel: #{cc[:faltan].join(', ')}"
        else
          if validacion.save
            # Asigna unas variables
            validacion.excel = path.to_s
            validacion.cabecera = cc[:asociacion]

            if Rails.env.production?
              validacion.delay(queue: 'validaciones').valida_campos
            end
              validacion.valida_campos
          end
        end

      end  # Fin errores empty
    end  # Fin del tipo de archivo
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
    columnas = Validacion::COLUMNAS_OPCIONALES.merge(Validacion::COLUMNAS_OBLIGATORIAS)
    columnas_obligatoraias = Validacion::COLUMNAS_OBLIGATORIAS.keys.map{|c| c.to_s}
    columnas_asociadas = Hash.new

    cabecera.each do |c|
      next unless c.present?  # para las columnas que son cabeceras y estan vacias
      cab = I18n.transliterate(c).gsub(' ','_').gsub('-','_').downcase.strip
      col_coincidio = columnas.map{ |k,v| v.include?(cab) ? k : nil }
      columnas_asociadas[col_coincidio.compact.first.to_s] = "^#{c}$" if col_coincidio.compact.count == 1
    end

    faltantes = columnas_obligatoraias - columnas_asociadas.keys
    columnas_faltantes = faltantes.map{|cf| t("columnas_obligatorias_excel.#{cf}")}

    {faltan: columnas_faltantes, asociacion: columnas_asociadas}
  end
end