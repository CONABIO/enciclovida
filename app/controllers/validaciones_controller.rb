class ValidacionesController < ApplicationController
  # Estas validaciones son los records que provienen desde SQL Server directamente (MS Access), ademas
  # de las validaciones de los archivos en excel, csv o taxones que copien y peguen en la caseta de texto

  # El request sigue siendo inseguro, hasta no poder hacer la conexion con un webservice con WSDL
  # desde SQL Server

  #Quita estos metodos para que pueda cargar correctamente la peticion
  skip_before_filter  :verify_authenticity_token, :set_locale, only: [:update, :insert, :delete]
  before_action :authenticate_request!, only: [:update, :insert, :delete]
  before_action :tipo_validacion, only: [:simple, :avanzada]
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

    if params[:lista].present?  # Valida por una lista de nombres cientificos al vuelo
      validacion = ValidacionSimple.new
      validacion.lista = params[:lista]
      resp = validacion.valida_lista

      if resp[:estatus]
        @coincidencias = validacion.recurso_validado
        resp = validacion.guarda_excel

        if resp[:estatus]
          @excel_url = resp[:excel_url]  # Guarda el excel para poder consumirlo en la respuesta, a lo mas 200
        end

      else
        @errores << resp[:msg]
      end

    else  # entonces trata de validar por archivo
      if @modelo[:estatus]
        resp = valida_archivo(@modelo[:tipo_validacion])

        if resp[:estatus]
          @subio_excel = resp[:estatus]
        else
          @errores << resp[:msg]
        end
      else
        @errores << @modelo[:msg]
      end  # End @modelo

    end  # End lista.present?
  end

  # Validacion a traves de un excel .xlsx y que conlleva mas columnas a validar
  def avanzada
    if @modelo[:estatus]
      resp = valida_archivo(@modelo[:tipo_validacion])

      if resp[:estatus]
        @subio_excel = resp[:estatus]
      else
        @errores << resp[:msg]
      end
    else
      @errores << @modelo[:msg]
    end  # End @modelo
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
    File.open(archivo_copia, 'wb') do |file|
      file.write(params[:archivo].read)  # Hace una copia del excel, para dejar las columnas originales
    end

    if File.exists?(archivo_copia)
      {estatus: true, archivo_copia: archivo_copia.to_s}
    else
      {estatus: false, msg: 'El archivo copia no se creo'}
    end
  end

  def comprueba_columnas(cabecera, validacion)
    columnas = validacion::COLUMNAS_OPCIONALES.merge(validacion::COLUMNAS_OBLIGATORIAS)
    columnas_obligatoraias = validacion::COLUMNAS_OBLIGATORIAS.keys.map{|c| c.to_s}
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

  def valida_archivo(validacion)
    return {estatus: false,  msg: 'No se subió ningún archivo o lista, por favor verifica'} unless params[:archivo].present?
    return {estatus: false, msg: "La extension \"#{params[:archivo].content_type}\" no esta permitida, las validas son: #{Validacion::FORMATOS_PERMITIDOS.join(', ')}"} unless Validacion::FORMATOS_PERMITIDOS.include?(params[:archivo].content_type)
    return {estatus: false, msg: 'No fue anotado ningún correo para la validación o se inicio sesión'} if params[:correo].blank? && !usuario_signed_in?
    copia = crea_copia_archivo
    return {estatus: false, msg: copia[:msg]} unless copia[:estatus]

    puts params[:action].inspect
    # Por si no cumple con las columnas obligatorias
    xlsx = Roo::Excelx.new(copia[:archivo_copia])
    sheet = xlsx.sheet(0)  # toma la primera hoja por default
    cabecera = sheet.row(1)
    cc = comprueba_columnas(cabecera, validacion)
    return {estatus: false, msg: "Algunas columnas obligatorias no fueron encontradas en tu excel: #{cc[:faltan].join(', ')}"} if cc[:faltan].any?

    # Asigna unas variables
    validacion = validacion.new
    validacion.archivo_copia = copia[:archivo_copia]
    validacion.nombre_archivo = params[:archivo].original_filename
    validacion.cabecera = cc[:asociacion]

    # Para asignar el correo
    if usuario_signed_in?
      validacion.correo = current_usuario.email
    else
      if Usuario::CORREO_REGEX.match(params[:correo])
        validacion.correo = params[:correo]
      else
        return {estatus: false, msg:'El correo que proporcionaste no es válido, por favor verifica.'}
      end
    end

    if Rails.env.production?
      validacion.delay(queue: 'validaciones').valida_archivo
    else
      validacion.valida_archivo
    end

    {estatus: true}
  end

  def tipo_validacion
    tipos = %w(simple avanzada)

    @modelo = if params[:action].present? && tipos.include?(params[:action])
                {estatus: true, tipo_validacion: "Validacion#{params[:action].capitalize}".constantize}
              else
                {estatus: false, msg: 'Lo sentimos, ocurrio un error en la acción que consultaste.'}
              end
  end

end