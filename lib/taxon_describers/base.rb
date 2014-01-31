module TaxonDescribers
  class Base
    class_attribute :describer

    def self.method_missing(method, *args)
      self.describer = new unless describer.is_a?(self)
      self.describer.send(method, *args)
    end
  end
end
