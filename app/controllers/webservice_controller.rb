class WebserviceController < ApplicationController
  #soap_service namespace: 'urn:WashOut'
  #soap_action 'prueba', :args => :integer, :return => :string

  # Su uso
  # client = Savon::Client.new(wsdl: "http://localhost:4000/webservice/wsdl")
  # client.call(:prueba, message: {:value => 10}).to_json
  def prueba
    render :soap => "---WEBSERVICE con param: #{params[:value]}---"
  end

  def bdi_nombre_cientifico
    #@pagina = params['pagina']
    @nombre = params['nombre']
    @fotos = nil
    bdiws = BDIService.new
    bdi=bdiws.dameFotos({nombre: @nombre, campo: 528})
    fotos=[]
    bdi[:fotos].each do |x|
      hash = {}
      hash[:large_url] = x.large_url
      hash[:medium_url] = x.medium_url
      hash[:native_page_url] = x.native_page_url
      hash[:license] = x.license
      hash[:square_url] = x.square_url
      hash[:native_realname] = x.native_realname
      fotos << hash
    end
    bdi[:fotos]=fotos
    

    if bdi[:estatus] == 'OK'
      #@fotos = bdi[:fotos]

      respond_to do |format|
        format.json {render json: bdi}
        format.html do

          # El conteo de las paginas
          totales = 0
          por_pagina = 25

          # Por ser la primera saco el conteo de paginas
          if @pagina.blank?
            # Saca el conteo de las fotos de bdi
            if bdi[:ultima].present?
              totales+= por_pagina*(bdi[:ultima]-1)
              fbu = @especie.fotos_bdi({pagina: bdi[:ultima]})
              totales+= fbu[:fotos].count if fbu[:estatus] == 'OK'
              @paginas = totales%por_pagina == 0 ? totales/por_pagina : (totales/por_pagina) +1
            end
          end  # End pagina blank
        end  # End format html
      end  # End respond

    else  # End estatus OK
      render :_error and return
    end
  end
end
