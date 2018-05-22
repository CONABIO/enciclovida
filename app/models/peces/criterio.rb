class Criterio < ActiveRecord::Base

  establish_connection(:peces)
  self.table_name='criterios'

  has_many :peces_criterios, :class_name => 'PezCriterio', :foreign_key => :criterio_id
  has_many :peces, :through => :peces_criterios, :source => :pez

  belongs_to :propiedad

  def self.catalogo

    resp = Rails.cache.fetch('criterios_catalogo') do
      grouped_options = {}

      Criterio.select(:id, :propiedad_id).group(:propiedad_id).each do |c|
        prop = c.propiedad
        llave_unica = prop.ancestors.map(&:nombre_propiedad).join('/')

        grouped_options[llave_unica] = [] if !grouped_options.key?(llave_unica)
        grouped_options[llave_unica] << [prop.nombre_propiedad, c.id]
      end

      grouped_options
    end

    resp
  end

  # Cache de algunas cosas
  def escribe_cache(recurso, tiempo = 1.day)
    Rails.cache.write(recurso, :expires_in =>tiempo)
  end

  def existe_cache?(recurso)
    Rails.cache.exist?(recurso)
  end

  def borra_cache(recurso)
    Rails.cache.delete(recurso)
  end

end