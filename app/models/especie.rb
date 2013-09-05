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

  CON_REGION = [19, 50]
  ESTATUSES = [
      [2, 'Activo'],
      [1, 'Inactivo']
  ]


  def self.dameRegionesNombresBibliografia(especie, detalles=nil)
    region="<div style='max-width:700px; overflow-x: scroll;'><table cellpadding='20'><tr>"

    if especie.especies_regiones.count > 0

      especie.especies_regiones.each do |e|
        region+="<td style='min-width:200px;'><ul>"

        if !e.region.is_root?
          e.region.ancestor_ids.each do |a|
            subregion=Region.find(a)

            if !subregion.is_root?
              region+="<li>#{subregion.nombre_region} (#{subregion.clave_region})</li>"
            end
          end
        end

        region+="<li>#{e.region.nombre_region} (#{e.region.clave_region})</li></ul>"

        region+='<ol>'
        e.nombres_regiones.where(:region_id => e.region_id).each do |n|
          region+="<li>#{n.nombre_comun.nombre_comun} (#{n.nombre_comun.lengua.downcase})</li>"
          n.nombres_regiones_bibliografias.where(:region_id => n.region_id).where(:nombre_comun_id => n.nombre_comun_id).each do |b|

            if detalles
              region+="<p><b>Bibliografía:</b> #{b.bibliografia.autor}</p>"
            else
              region+="<p><b>Bibliografía:</b> #{b.bibliografia.autor.truncate(25)}</p>"
            end

          end
        end
        region+='</ol>'

        if e.tipo_distribucion_id.nil?
          if e.region.is_root?
            region+='</td>'

          else
            region+='<b>Distribución:</b> SD</td>'
          end

        else
          region+="<b>Distribución:</b> #{e.tipo_distribucion.descripcion}</td>"
        end


      end

    elsif CON_REGION.include?(especie.categoria_taxonomica_id)
      region='<td>ND</td>'

    else
      region=''
    end

    region + '</tr></table></div>'
  end


  def self.dameEstadoDeConservacion(especie)
    conservacion='<ul>'

    especie.especies_catalogos.each do |c|
      conservacion+="<li>#{c.catalogo.descripcion}</li>"
    end

    conservacion+='</ul>'
  end


  def self.dameIdsDelNombre(nombre, tipo=nil)
    identificadores=''

    sentencia="SELECT nr.especie_id AS ids FROM nombres_regiones nr
    LEFT JOIN nombres_comunes nc ON nc.id=nr.nombre_comun_id
    WHERE lower_unaccent(nc.nombre_comun) LIKE lower_unaccent('%#{nombre}%')"

    if tipo.nil?
      sentencia+="UNION SELECT e.id from especies e WHERE lower_unaccent(e.nombre) LIKE lower_unaccent('%#{nombre}%')"
    end

    sentencia=Especie.find_by_sql(sentencia)

    sentencia.each do |i|
      identificadores+="#{i.ids}, "
    end

    identificadores[0..-3]
  end


  def self.dameIdsDeLaRegion(nombre)
    identificadores=''
    sentencia=Especie.find_by_sql("SELECT DISTINCT er.especie_id AS ids FROM especies_regiones er
                              LEFT JOIN regiones r ON er.region_id=r.id
                              WHERE lower_unaccent(r.nombre_region) LIKE lower_unaccent('%#{nombre}%') ORDER BY ids")

    sentencia.each do |i|
      identificadores+="#{i.ids}, "
    end

    identificadores[0..-3]
  end


  def self.dameIdsDeLaDistribucion(distribucion)
    identificadores=''
    sentencia=Especie.find_by_sql("SELECT DISTINCT er.especie_id AS ids FROM especies_regiones er
                                    WHERE tipo_distribucion_id=#{distribucion} ORDER BY ids;")

    sentencia.each do |i|
      identificadores+="#{i.ids}, "
    end

    identificadores[0..-3]
  end

end
