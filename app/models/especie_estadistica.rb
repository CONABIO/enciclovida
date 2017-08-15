class EspecieEstadistica < ActiveRecord::Base

  belongs_to :estadistica
  belongs_to :especie
end
