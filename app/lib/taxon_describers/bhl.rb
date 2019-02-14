module TaxonDescribers

  class Bhl < Base

    def self.describer_name
      'BHL'
    end

    def self.describe(taxon)
      puts "taxon  de bHL y contengo #{taxon.id} \n"
      url = "http://localhost:3000/especies/#{taxon.id}/bhl"
      puts "voy a buscar en #{url}"
      escaped_address = URI.escape(url)
      uri = URI.parse(escaped_address)
      #response = Net::HTTP.get(uri)
      doc = Nokogiri::HTML(open(uri))

    end
  end
end