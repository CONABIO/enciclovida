class Especie < ActiveRecord::Base

  self.table_name='especies'
  belongs_to :categoria_taxonomica
  has_many :especies_regiones, :class_name => 'EspecieRegion', :foreign_key => 'especie_id'
  has_many :especies_catalogos, :class_name => 'EspecieCatalogo', :foreign_key => 'especie_id'
  has_ancestry :ancestry_column => :ancestry_acendente_directo

  scope :caso_insensitivo, ->(columna, valor) { where("lower_unaccent(#{columna}) LIKE lower_unaccent('%#{valor}%')") }
  scope :caso_sensitivo, ->(columna, valor) { where("#{columna}=#{valor}") }
  scope :caso_ids, ->(columna, valor) { where("CAST(#{columna} AS TEXT) LIKE '%#{valor}%'") }
  scope :ordenar, ->(columna, orden) { order("#{columna} #{orden}") }
  scope :datos, -> { joins('LEFT JOIN especies_regiones ON especies.id=especies_regiones.especie_id').
      joins('LEFT JOIN categoria_taxonomica')}
  scope :nombres, ->(ids) { find(ids) }

  CON_REGION = [19, 50]
  ESTATUSES = ['Activo', 'Inactivo']


  def self.dameRegionesNombresBibliografia(especie)
    region='<table><tr>'

    if especie.especies_regiones.count > 0

      especie.especies_regiones.each do |e|
        region+="<td><ul id='lista_region'>"

        if !e.region.is_root?
          e.region.ancestor_ids.each do |a|
            subregion=Region.find(a)

            if !subregion.is_root?
              region+="<li>#{subregion.nombre_region}(#{subregion.clave_region})</li>"
            end
          end
        end

        region+="<li>#{e.region.nombre_region}(#{e.region.clave_region})</li></ul>"

        region+='<ol>'
        e.nombres_regiones.where(:region_id => e.region_id).each do |n|
          region+="<li>#{n.nombre_comun.nombre_comun.titleize}(#{n.nombre_comun.lengua.titleize})</li>"
          n.nombres_regiones_bibliografias.where(:region_id => n.region_id).where(:nombre_comun_id => n.nombre_comun_id).each do |b|
            region+="<p>#{b.bibliografia.autor.truncate(25)}</p>"
          end
        end
        region+='</ol>'

        if e.tipo_distribucion_id.nil?
          if e.region.is_root?
            region+='</td>'

          else
            region+='- SD</td>'
          end

        else
          region+="- #{e.tipo_distribucion.descripcion}</td>"
        end


      end

    elsif CON_REGION.include?(especie.categoria_taxonomica_id)
      region='<td>ND</td>'

    else
      region=''
    end

    region + '</tr></table>'
  end


  def self.dameEstadoDeConservacion(especie)
    conservacion='<ul>'

    especie.especies_catalogos.each do |c|
      conservacion+="<li>#{c.catalogo.descripcion}</li>"
    end

    conservacion+='</ul>'
  end

  def self.dameIdsDelNombre(nombre)
    idsEspecie=Especie.caso_insensitivo('nombre', nombre)
    ids
  end

end
