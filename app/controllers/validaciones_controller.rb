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
        uploader.store!(params[:excel])
        xlsx = Roo::Excelx.new(params[:excel].path, nil, :ignore)
        @sheet = xlsx.sheet(0)  # toma la primera hoja por default

        rows = @sheet.last_row - @sheet.first_row  # Para quietarle del conteo la cabecera
        columns = @sheet.last_column

        @errores << 'La primera hoja de tu excel no tiene información' if rows < 0
        @errores << 'Las columnas no son las mínimas necesarias para poder leer tu excel' if columns < 7

        if @errores.empty?
          cabecera = @sheet.row(1)
          cco = comprueba_columnas_obligatorias(cabecera)

          if cco.any?
            @errores << "Algunas columnas obligatorias no fueron encontradas en tu excel: #{cco.join(', ')}"
          end
        end
      end

    rescue CarrierWave::IntegrityError => c
      @errores << c
    end
  end

  private

  def comprueba_columnas_obligatorias(cabecera)
    columnas_obligatoraias = %w(familia genero especie autoridad infraespecie categoria nombre_cientifico)
    columnas_faltantes = []

    cabecera.each do |c|
      cab = I18n.transliterate(c).gsub(' ','_').gsub('-','_').downcase
      columnas_obligatoraias.delete(cab) if columnas_obligatoraias.include?(cab)
    end

    columnas_obligatoraias.compact.each do |col_obl|
      columnas_faltantes << t("columnas_obligatorias_excel.#{col_obl}")
    end

    columnas_faltantes
  end

  def authenticate_request!
    return nil unless CONFIG.ip_sql_server.include?(request.remote_ip)
    return nil unless params[:secret] == CONFIG.secret_sql_server.to_s.parameterize
    return nil if params[:id].blank? || params[:base].blank? || params[:tabla].blank?
    return nil unless CONFIG.bases.include?(params[:base])
    return nil unless Bases::EQUIVALENCIA.include?(params[:tabla])
  end
end