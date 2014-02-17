require ::File.expand_path('../../conabio_service.rb', __FILE__)
require ::File.expand_path('../base.rb', __FILE__)

module TaxonDescribers
  class Conabio < Base
    def self.describe(taxon)
      page = conabio_service.search(taxon.nombre_cientifico)
      page.blank? ? nil : page
    end

    private
    def conabio_service
      @conabio_service=ConabioService.new
    end
  end
end