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

  def geojson_to_topojson

    collection = params[:geojson]
    puts collection.inspect
    #collection = open('/home/ggonzalez/Descargas/geojson_estados.json').read

    source = open('./lib/assets/topojson.js').read
    ExecJS.runtime = ExecJS::Runtimes::Node
    context = ExecJS.compile(source)

    topojson = context.eval("topojson.topology({collection: #{collection} }, 1e4)")

    respond_to do |format|
      format.json {render json: topojson}
      format.html do

      end  # End format html
    end

  end

end
