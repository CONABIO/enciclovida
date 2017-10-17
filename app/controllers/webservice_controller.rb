class WebserviceController < ApplicationController
  protect_from_forgery with: :null_session

  def bdi_nombre_cientifico
    @nombre = params['nombre']
    bdi = BDIService.new.dameFotos({nombre: @nombre, campo: 528})

    if bdi[:estatus] == 'OK'

      #Esto para que funcione el servicio para la app buena pesca, posteriormente se debe especificar si se desean más de 5 imágenes
      bdi[:fotos] = bdi[:fotos][0..5]

      respond_to do |format|
        format.json {render json: bdi}
        format.html do

        end  # End format html
      end  # End respond

    else  # End estatus OK
      render :_error and return
    end
  end

  def geojson_a_topojson
    topo = GeoATopo.new
    topojson = {}
    topojson[:estatus] = false

    if params[:region_id].present? && params[:tipo_region].present?
      begin
        reg = params[:tipo_region].camelize.constantize
        res = params[:tipo_region] == 'municipio' ? reg.geojson(params[:region_id], params[:parent_id]) : reg.geojson(params[:region_id])

        if res.length == 1
          topojson[:estatus] = true
          topojson[:topojson] = topo.dame_topojson(res.first.geojson)
        else
          topojson[:msg] = "No hubo resultados en la base para el geojson con la region: #{params[:region_id]}"
        end

      rescue => e
        topojson[:msg] = "No pudo generar el topojson: #{e.message}"
      end

    elsif params[:geojson]
      topojson[:estatus] = true
      topojson[:topojson] = topo.dame_topojson(params[:geojson])
    else
      topojson[:msg] = 'Los parametros mínimos no fueron mandados'
    end

    render json: topojson
  end

end
