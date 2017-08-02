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

  # Vista de la validacion simple y avanzada
  def index
  end

  # Es una validacion solo con el nombre cientifico, ya sea por medio de una lista o archivo
  def simple
    @errores = []

    if params[:lista].present?
      validacion = ValidacionSimple.new
      validacion.lista = params[:lista]
      resp = validacion.valida_lista

      if resp[:estatus]
        @coincidencias = validacion.lista_validada
      else
        @errores << resp[:obs]
      end

    elsif params[:archivo].present?  # entonces trata de validar por archivo

      if params[:archivo].blank? || !Validacion::FORMATOS_PERMITIDOS.include?(params[:archivo].content_type)
        @errores << "La extension \"#{params[:archivo].content_type}\" no esta permitida, las validas son: xlsx, csv, txt"
      else
        copia = crea_copia_archivo
        @errores << copia[:msg] if !copia[:estatus]

        if @errores.empty?

          if params[:archivo].content_type == application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
            xlsx = Roo::Excelx.new(params[:archivo].to_s)
            sheet = xlsx.sheet(0)  # toma la primera hoja por default
            cabecera = sheet.row(1)
            cc = comprueba_columnas_simple(cabecera)

            # Por si no cumple con las columnas obligatorias
            if cc
              @errores << "No se encontro la columna \"nombre_cientifico\" en tu excel, por favor verifica"
            else
              validacion = Validacion.new(nombre_archivo: params[:archivo].original_filename)

              if validacion.save
                # Asigna unas variables
                validacion.archivo = copia[:archivo]
                validacion.cabecera = ['nombre_cientifico']

                if Rails.env.production?
                  validacion.delay(queue: 'validaciones').valida_campos
                end
                validacion.valida_campos
              end
            end
          end  # Fin de archivo excel

        end  # Fin errores empty
      end  # Fin del tipo de archivo

    else
      @errores << 'Por lo menos debe haber un lista o un archivo'
    end

  end

  # Validacion a traves de un excel .xlsx y que conlleva mas columnas a validar
  def avanzada
    @errores = []

    if params[:archivo].blank? || params[:archivo].content_type != Validacion::FORMATO_AVANZADA
      @errores << "La extension \"#{params[:archivo].content_type}\" no esta permitida, las valida es : xlsx"
    else
      copia = crea_copia_archivo
      @errores << copia[:msg] if !copia[:estatus]

      if @errores.empty?
        xlsx = Roo::Excelx.new(params[:archivo].to_s)
        sheet = xlsx.sheet(0)  # toma la primera hoja por default
        cabecera = sheet.row(1)
        cc = comprueba_columnas_avanzada(cabecera)

        # Por si no cumple con las columnas obligatorias
        if cc[:faltan].any?
          @errores << "Algunas columnas obligatorias no fueron encontradas en tu excel: #{cc[:faltan].join(', ')}"
        else
          validacion = Validacion.new(nombre_archivo: params[:archivo].original_filename)

          if validacion.save
            # Asigna unas variables
            validacion.archivo = copia[:archivo]
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

  def crea_copia_archivo
    nombre_archivo = "#{Time.now.strftime("%Y%m%d%H%M%S")}_#{params[:archivo].original_filename}"

    # Creando la carpeta del usuario y gurdando el archivo
    ruta_archivo = Rails.root.join('public','validaciones', Time.now.strftime("%Y%m%d"))
    FileUtils.mkpath(ruta_archivo, :mode => 0755) unless File.exists?(ruta_archivo)

    archivo_copia = ruta_archivo.join("tmp_#{nombre_archivo}")
    File.open(archivo_copia, 'w+') do |file|
      file.write(params[:archivo].read)  # Hace una copia del excel, para dejar las columnas originales
    end.close

    if File.exists?(archivo_copia)
      {estatus: true, archivo: archivo_copia.to_s}
    else
      {estatus: false, msg: 'El archivo copia no se creo'}
    end
  end

  def comprueba_columnas_avanzada(cabecera)
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

  def comprueba_columnas_simple(cabecera)
    cabecera.each do |c|
      next unless c.present?  # para las columnas que son cabeceras y estan vacias
      cab = I18n.transliterate(c).gsub(' ','_').gsub('-','_').downcase.strip

      return true if cab == 'nombre_cientifico'
    end

    false  # Si llego aqui, quiere decir que no encontro la columna nombre cientifico
  end
end