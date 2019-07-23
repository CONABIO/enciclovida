module TaxonDescribers
  
  class WikipediaEs < Wikipedia
    def wikipedia
      @wikipedia ||= WikipediaService.new(:locale => "es")
    end

    def self.describer_name
      'Wikipedia (español)'
    end

    def page_url(taxon)
      "http://es.wikipedia.org/wiki/#{taxon.nombre_cientifico.limpiar.limpia}"
    end
  end

end
