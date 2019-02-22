module TaxonDescribers
  class Janium < Base
    def describe(taxon, options={})

      client2 = Savon.client(
          :wsdl => "http://200.12.166.51/janium/services/soap.pl",
          :open_timeout => 10,
          :read_timeout => 10,
          :log => false
      )



      client = Savon.client do
        endpoint "http://200.12.166.51/janium/services/soap.pl"
        namespace "http://janium.net/services/soap"
      end



      response = client.call('RegistroBib/BuscarPorPalabraClaveGeneral') do
        message a: "terminos", v: "panthera+onca"
      end

      response = client.call('Sistema/Ping') do
        message a: "terminos", v: "panthera+onca"
      end

      body_hash = {}
      body_hash['method'] = 'RegistroBib/BuscarPorPalabraClaveGeneral'
      body_hash['a'] = "RegistroBib/BuscarPorPalabraClaveGeneral"


      response = client.call(:JaniumRequest, message: body_hash)


    end

    def page_url(taxon)

    end

    def self.describer_name

    end

    def data_objects_from_page(page, options = {})

    end

    protected
    def janium_service

    end
  end
end


##
#
# criterios de busqueda a enviar durante una consulta
# name="metodo" value="RegistroBib/BuscarPorPalabraClaveGeneral">
# name="a" value="terminos">
# name="inicio" value="1">
# name="v" id="busqueda">
#
# Forma en que se llama:
# $client->callWs($_GET['metodo'], $_GET['a'], $_GET['v'], $_GET['numero_de_pagina']);
#
#
# Respuesta
# $fichas = $client->iteraResultados();