module ActiveRecord
  module Timestamp

    private

    def timestamp_attributes_for_update #:nodoc:
      [:FechaModificacion]
    end
  end
end