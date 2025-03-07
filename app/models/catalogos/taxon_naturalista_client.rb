require 'httparty'

class TaxonNaturalistaClient
  include HTTParty
  base_uri 'https://www.snib.mx/slim/src/public/v1'

  def self.fetch_taxa(scientific_name)
    get('/taxonNaturalista', query: { name: scientific_name })
  end
end