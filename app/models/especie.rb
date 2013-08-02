class Especie < ActiveRecord::Base

  self.table_name='especies'
  belongs_to :categoria_taxonomica
  has_many :especies_regiones, :class_name => 'EspecieRegion', :foreign_key => 'especie_id'
  has_ancestry :ancestry_column => :ancestry_acendente_directo

  scope :caso_insensitivo, ->(columna, valor) { where("LOWER(#{columna}) LIKE LOWER('%#{valor}%')") }
  scope :caso_sensitivo, ->(columna, valor) { where("#{columna}=#{valor}") }
  scope :caso_ids, ->(columna, valor) { where("CAST(#{columna} AS TEXT) LIKE '%#{valor}%'") }
  scope :ordenar, ->(columna, orden) { order("#{columna} #{orden}") }
  scope :datos, -> { joins("LEFT JOIN especies_regiones ON especies.id=especies_regiones.especie_id").
      joins("LEFT JOIN categoria_taxonomica")}

  CON_REGION = [19, 50]

  def self.dameRegionesNombresBibliografia(especie)
    region="<table border='1'><tr>"

    if especie.especies_regiones.count > 0

      especie.especies_regiones.each do |e|
        region+="<td>"
        #region+="<td>#{e.region.nombre_region}(#{e.region.clave_region})"

        if !e.region.is_root?

          e.region.ancestor_ids.each do |a|
            subregion=Region.find(a)
            region+="#{subregion.nombre_region}(#{subregion.clave_region}) => "
          end

        end

        region+="#{e.region.nombre_region}(#{e.region.clave_region})"



        if e.tipo_distribucion_id.nil?
          if e.region.is_root?
            region+="<br></td>"

          else
            region+="<br>SD</td>"
          end

        else
          region+="<br>#{e.tipo_distribucion.descripcion}</td>"
        end
      end

    elsif CON_REGION.include?(especie.categoria_taxonomica_id)
      region='<td>ND</td>'

    else
      region=''
    end

    region + '</tr></table>'
  end

end
