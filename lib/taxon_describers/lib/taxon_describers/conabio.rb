module TaxonDescribers
  class Conabio < Base

    def self.describer_name
      'CONABIO'
    end

    def self.describe(taxon)
      page = conabio_service.search(taxon.nombre_cientifico.limpiar.limpia)
      page.blank? ? nil : page
    end

    private
    def conabio_service
      @conabio_service=New_Conabio_Service.new(:timeout => 20)
    end
  end
end