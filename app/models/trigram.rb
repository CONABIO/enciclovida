class Trigram < ActiveRecord::Base
  include Fuzzily::Model
  self.table_name = 'trigrams'
end
