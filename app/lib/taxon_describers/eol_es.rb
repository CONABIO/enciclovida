module TaxonDescribers
  
  class EolEs < Eol
    def self.describer_name
      'EOL (español)'
    end

    def describe(taxon, options={})
      super(taxon, options)
    end
  end

end
