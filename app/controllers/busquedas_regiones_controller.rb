class BusquedasRegionesController < ApplicationController

  skip_before_action :verify_authenticity_token, :set_locale
  layout false, only: [:especies, :ejemplares]

  # Registros con un radio alreadedor de tu ubicación
  def ubicacion
  end

  # /explora-por-region
  def por_region
    @no_render_busqueda_basica = true
    cache_filtros_ev
  end

  # Servicio para consultar las especies pr region, contempla filtros y cache
  def especies
    br = BusquedaRegion.new
    br.params = params

    respond_to do |format|
      format.html do
        cache_filtros_ev
        br.especies
        @resp = br.resp 
      end
      format.xlsx do
        br.original_url = request.original_url
        br.descarga_taxa_excel
        render json: br.resp 
      end
      format.json do
        br.especies
        render json: br.resp 
      end
    end
  end

  # Regresa todos los registros de la especie seleccionada
  def ejemplares
    snib = Geoportal::Snib.new
    snib.params = params
    snib.ejemplares

    render json: snib.resp
  end

  # Regresa la información asociada a un ejemplar por medio de su ID
  def ejemplar
    snib = Geoportal::Snib.new
    snib.params = params
    snib.ejemplar

    render json: snib.resp
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

  # Descarga el listado de especies por region
  def descarga_taxa
    lista = Lista.new
    columnas = Lista::COLUMNAS_DEFAULT + Lista::COLUMNAS_RIESGO_COMERCIO + Lista::COLUMNAS_CATEGORIAS_PRINCIPALES
    lista.columnas = columnas.join(',')
    lista.formato = 'xlsx'
    lista.usuario_id = 0  # Quiere decir que es una descarga, la guardo en lista para tener un control y poder correr delayed_job

    # Para saber si el correo es correcto y poder enviar la descarga
    if  Usuario::CORREO_REGEX.match(params[:correo]) ? true : false
      # el nombre de la lista es cuando la solicito y el correo
      lista.nombre_lista = Time.now.strftime("%Y-%m-%d_%H-%M-%S-%L") + "_taxa_EncicloVida|#{params[:correo]}"

      br = BusquedaRegion.new
      br.params = params
      #br.especies_por_grupo

      # Una vez obtenida la respuesta del servicio o del cache iteramos en la base
      if br.resp[:estatus]
        lista.cadena_especies = br.resp[:resultados].map{|t| t[:id]}.join(',')

        if Rails.env.production?
          lista.delay(queue: 'descargar_taxa').to_excel({ubicaciones: true, correo: params[:correo]}) if lista.save
        else  # Para develpment o test
          lista.to_excel({ubicaciones: true, correo: params[:correo]}) if lista.save
        end

        render json: {estatus: true}

      else
        render json: br.resp
      end

    else  # Por si no puso un correo valido
      render json: {estatus: false, msg: 'El correo no es válido.'}
    end
  end

end

