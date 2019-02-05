module TaxonDescribers

  class Bhl < Base

    def self.describer_name
      'BHL'
    end

    def self.describe(taxon)
      puts "hola mundo estoy en taxon y soy el de bHL y contengo #{taxon} \n"
      page = bhl_service.rescuApi(taxon.strip)
      page.blank? ? nil : page
      # puts "aqui ponemos lo que tiene page"
      # puts page.class
    end

    private
    def bhl_service
      @bhl_service = BhlService.new
    end

  end


end