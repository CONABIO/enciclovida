class UbicacionesController < ApplicationController

  skip_before_filter :verify_authenticity_token, :set_locale

  # Registros con un radio alreadedor de tu ubicación
  def ubicacion
  end

  # /explora-por-region
  def por_region
  end

  # Regresa el conteo por grupo del servicio de Abraham, no lo hago directo porque lo guardo en cache ya que
  # algunas peticiones tardan 20 segundos
  def conteo_por_grupo
    begin
      rest = RestClient.get "#{CONFIG.ssig_api}/taxonEdo/conteo/total/#{params[:region_id]}?apiKey=enciclovida"
      conteo = JSON.parse(rest)

      if conteo.kind_of?(Hash) && conteo['error'].present?
        resp = {estatus: false, msg: conteo['error']}
      else
        resp = {estatus: true, resultados: conteo}
      end
    rescue => e
      resp =  {estatus: false, msg: e.message}
    end

    render json: resp
  end

  def especies_por_catalogo_id
    if params[:catalogo_id].present?
      resultados = []

      Especie.where(catalogo_id: params[:catalogo_id]).each do |taxon|
        next unless p = taxon.proveedor
        geodatos = p.geodatos
        next unless geodatos.any?

        resultados << {nombre_cientifico: taxon.nombre_cientifico, snib_mapa_json: geodatos[:snib_mapa_json]}

        if a = taxon.adicional
          resultados.last.merge!(nombre_comun: a.nombre_comun_principal, foto: a.foto_principal)
        end

      end  # each taxon

      render json: {estatus: true, resultados: resultados}

    else
      render json: {estatus: false, msg: 'No hubo especies'}
    end  # End catalogo_id present
  end

  def especies_por_nombre_cientifico
    especies_hash = {}
    resultados = []

    params[:especies].each do |e|
      cad = e.split('-')
      especies_hash[cad.first] = cad.last.to_i
    end

    taxones = Especie.select('especies.id, nombre_cientifico, especies.catalogo_id, nombre_comun_principal, foto_principal').adicional_join.where(nombre_cientifico: especies_hash.keys)
    taxones = Busqueda.filtros_default(taxones, params).distinct

    taxones.each do |taxon|
      resultados << {id: taxon.id, nombre_cientifico: taxon.nombre_cientifico, catalogo_id: taxon.catalogo_id, nombre_comun: taxon.nombre_comun_principal, foto: taxon.foto_principal, nregistros: especies_hash[taxon.nombre_cientifico]}
    end

    render json: {estatus: true, resultados: resultados}
  end

  # Devuelve los municipios por el estado seleccionado
  def municipios_por_estado
    resp = {}
    resp[:estatus] = false

    if params[:region_id].present?
      resp[:estatus] = true
      parent_id = Estado::CORRESPONDENCIA[params[:region_id].to_i]
      municipios = Municipio.campos_min.where(cve_ent: parent_id)
      resp[:resultados] = municipios.map{|m| {region_id: m.region_id, nombre_region: m.nombre_region}}
      resp[:parent_id] = parent_id
    else
      resp[:msg] = 'El argumento region_id está vacio'
    end

    render json: resp
  end

  def busquedas_avanzada
    busqueda = Especie
    busqueda = Busqueda.filtros_default(busqueda, params)
    puts busqueda.to_sql
  end

  # Descarga el listado de especies por region
  def descarga_taxa
    lista = Lista.new
    columnas = Lista::COLUMNAS_DEFAULT + Lista::COLUMNAS_RIESGO_COMERCIO + Lista::COLUMNAS_CATEGORIAS_PRINCIPALES
    lista.columnas = columnas.join(',')
    lista.formato = 'xlsx'
    lista.cadena_especies = params[:especies].join(',')
    lista.usuario_id = 0  # Quiere decir que es una descarga, la guardo en lista para tener un control y poder correr delayed_job

    if params[:especies].length > 0
      # Para saber si el correo es correcto y poder enviar la descarga
      if  Usuario::CORREO_REGEX.match(params[:correo]) ? true : false
        # el nombre de la lista es cuando la solicito y el correo
        lista.nombre_lista = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + "_taxa_EncicloVida|#{params[:correo]}"

        if Rails.env.production?
          lista.delay(:priority => 2, queue: 'descargar_taxa').to_excel({ubicaciones: true, correo: params[:correo]}) if lista.save
        else  # Para develpment o test
          lista.to_excel({ubicaciones: true, correo: params[:correo]}) if lista.save
        end

        render json: {estatus: true}

      else  # Por si no puso un correo valido
        render json: {estatus: false, msg: 'El correo no es válido.'}
      end

    else  # No entro a ningun condicional, es un error
      render json: {estatus: false, msg: 'No hubo especies para descarga'}
    end  # end especies > 0
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_ubicacion
    @ubicacion = Metadato.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def ubicacion_params
    params.require(:ubicacion).permit(:path, :object_name, :artist, :copyright)
  end
end

