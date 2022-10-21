class WebserviceController < ApplicationController
  skip_before_action :set_locale
  protect_from_forgery with: :null_session
  layout Proc.new{['geojson_a_topojson'].include?(action_name) ? false : 'application_b3'}

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
