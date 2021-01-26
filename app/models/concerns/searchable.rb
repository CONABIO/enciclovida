module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

=begin
    mapping do
      # ...
    end
=end
    def self.search(query, opts={})
      #super
    end


  end
end