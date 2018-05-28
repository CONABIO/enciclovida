class PezPropiedad < ActiveRecord::Base

  establish_connection(Rails.env.to_sym)
  self.table_name='peces_propiedades'
  self.primary_keys = :especie_id, :propiedad_id

  belongs_to :pez, class_name: 'Pez', foreign_key: :especie_id
  belongs_to :propiedad

end