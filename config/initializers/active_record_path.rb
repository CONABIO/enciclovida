module ActiveRecord
  module Timestamp

    private

    def timestamp_attributes_for_update #:nodoc:
      [:FechaModificacion, :updated_at]
    end

    def timestamp_attributes_for_create #:nodoc:
      [:FechaCaptura, :created_at]
    end
  end
end