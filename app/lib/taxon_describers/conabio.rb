module TaxonDescribers
  class Conabio < Base

    def self.describer_name
      'CONABIO'
    end

    def self.describe(taxon)
      if cat = taxon.scat
        page = conabio_service.search(cat.catalogo_id)
        page.blank? ? nil : page
      end
    end

    private
    def conabio_service
      @conabio_service=New_Conabio_Service.new(:timeout => 20)
    end
  end
end