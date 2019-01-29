module TaxonDescribers

  class Bhl < Base

    def self.describer_name
      'BHL'
    end

    def self.describe(taxon)
      puts "hola mundo estoy en taxon y soy el de bHL y contengo #{taxon.nombre_cientifico} \n"
      page = bhl_service.rescuApi(taxon.nombre_cientifico)
      puts page
    end

    private
    def bhl_service
      @bhl_service = BhlService.new
    end

  end


end