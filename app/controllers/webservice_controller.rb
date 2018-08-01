class WebserviceController < ApplicationController
  skip_before_action :set_locale
  protect_from_forgery with: :null_session
  layout false, :only => [:geojson_a_topojson]

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

        if Rails.env.development?
          ruta = Rails.root.join('public', 'topojson')
          tipo_region = params[:tipo_region].split('_').last.estandariza
          
          archivo = if tipo_region == 'municipio'
                      nombre = "#{tipo_region}_#{params[:region_id]}_#{params[:parent_id]}.json"
                      ruta.join(nombre)
                    else
                      nombre = "#{tipo_region}_#{params[:region_id].to_i}.json"
                      ruta.join(nombre)
                    end

          # res = File.read(archivo) if File.exists?(archivo)
          #send_file archivo and return
          #exit(0)

          if File.exists?(archivo)
            res = "/topojson/#{nombre}"
            topojson[:cache] = true
          end
        else
          res = tipo_region.camelize.constantize
          res = tipo_region == 'municipio' ? res.geojson(params[:region_id], params[:parent_id]) : res.geojson(params[:region_id])
          res = topo.dame_topojson(res.first.geojson) if res.length == 1
        end

        topojson[:estatus] = true
        topojson[:topojson] = res

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
