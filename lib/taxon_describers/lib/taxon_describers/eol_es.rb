require ::File.expand_path('../eol', __FILE__)
module TaxonDescribers
  
  class EolEs < Eol
    def self.describer_name
      "EOL"
    end

    def describe(taxon, options={})
      super(taxon, options)
    end
  end

end
