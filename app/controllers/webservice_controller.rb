class WebserviceController < ApplicationController

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
end
