require ::File.expand_path('../wikipedia', __FILE__)
module TaxonDescribers
  
  class WikipediaEs < Wikipedia
    def wikipedia
      @wikipedia ||= WikipediaService.new(:locale => "es")
    end

    def self.describer_name
      "Wikipedia"
    end

    def page_url(taxon)
      #"http://es.wikipedia.org/wiki/#{taxon.wikipedia_title || taxon.name}"
      "http://es.wikipedia.org/wiki/#{taxon.nombre_cientifico}"
    end
  end

end
