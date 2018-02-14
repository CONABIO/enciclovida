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
    br = BusquedaRegion.new
    br.params = params
    br.cache_conteo_por_grupo

    render json: br.resp
  end

  def especies_por_grupo
    br = BusquedaRegion.new
    br.params = params
    br.especies_por_grupo

    # El paginado para que no se atasque
    por_pagina = 10
    pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    rango_inferior = por_pagina*(pagina - 1)
    rango_superior = por_pagina*pagina - 1

    br.resp[:totales] = br.resp[:resultados].count
    br.resp[:resultados] = br.resp[:resultados][rango_inferior..rango_superior]

    if br.resp[:resultados].nil?
      br.resp[:estatus] = false
      br.resp[:msg] = 'No hay más resultados'
    end

    render json: br.resp
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
      br.especies_por_grupo

      puts br.resp

      # Una vez obtenida la respuesta del servicio o del cache iteramos en la base
      if br.resp[:estatus]
        #puts br.resp[:resultados].inspect
=begin

        ids = []
        br.resp[:resultados].each do |r|
          #puts r[:id].class
          begin
          ids << r[:id]
          rescue
            next
          end
        end
=end
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

