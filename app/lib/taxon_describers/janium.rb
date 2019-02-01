module TaxonDescribers
  class Janium < Base

    def self.describer_name
      'Janium - Bioteca'
    end

    def self.describe(taxon)
      Rails.logger.debug "[DEBUG] JANIUM buscará #{taxon.nombre_cientifico.limpiar.limpia}"



      page = show_janium_records
      page.blank? ? nil : page
    end

    private
    def janium_service

    end
  end
end


=begin

module TaxonDescribers
  class Janium < Base
    def describe(taxon, options={})

      janium_location = "http://200.12.166.51/janium/services/soap.pl"
      janium_namespace = "http://janium.net/services/soap"
      janium_request = "JaniumRequest"

      @client = Savon.client(
          endpoint: janium_location,
          namespace: janium_namespace,
          logger:      Rails.logger,
          log_level:   :debug,
          log:         true,
          ssl_version: :TLSv1,
          pretty_print_xml: true
      )

      request_message = {
          :method => "RegistroBib/BuscarPorPalabraClaveGeneral",
          :arg => {
              a: "terminos",
              v: "panthera"
          }
      }

      res = @client.call("JaniumRequest", soap_action: "#{janium_namespace}##{janium_request}", message: request_message)

    end

    def gen_request_message(taxon_name)

    end

    def page_url(taxon)

    end

    def self.describer_name

    end

    def data_objects_from_page(page, options = {})

    end

    def authenticate(credentials)
      @client.call(:authenticate, message: credentials)
    rescue Savon::SOAPFault => error
      Logger.log error.http.code
      raise
    end


    protected
    def janium_service

    end
  end
end
=end