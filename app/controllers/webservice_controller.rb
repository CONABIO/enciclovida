class WebserviceController < ApplicationController
  soap_service namespace: 'urn:WashOut'
  soap_action 'prueba', :args => :integer, :return => :string

  # Su uso
  # client = Savon::Client.new(wsdl: "http://localhost:4000/webservice/wsdl")
  # client.call(:prueba, message: {:value => 10}).to_json
  def prueba
    render :soap => "---WEBSERVICE con param: #{params[:value]}---"
  end
end
