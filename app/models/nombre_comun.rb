class NombreComun < ActiveRecord::Base

  self.table_name='nombres_comunes'
  self.primary_key = 'id'

  has_many :nombres_regiones, :class_name => 'NombreRegion'
  has_many :especies, :through => :nombres_regiones, :class_name => 'Especie'

  scope :caso_insensitivo, ->(columna, valor) { where("LOWER(#{columna}) LIKE LOWER('%#{valor}%')") }
  scope :caso_empieza_con, ->(columna, valor) { where("#{columna} LIKE '#{valor}%'") }
  scope :caso_sensitivo, ->(columna, valor) { where("#{columna}='#{valor}'") }
  scope :caso_termina_con, ->(columna, valor) { where("#{columna} LIKE '%#{valor}'") }
  scope :caso_fecha, ->(columna, valor) { where("CAST(#{columna} AS TEXT) LIKE '%#{valor}%'") }
  scope :caso_rango_valores, ->(columna, rangos) { where("#{columna} IN (#{rangos})") }
  scope :especies_join, -> { joins('LEFT JOIN nombres_regiones ON nombres_regiones.nombre_comun_id=nombres_comunes.id').
      joins('LEFT JOIN especies ON especies.id=nombres_regiones.especie_id') }
  scope :categoria_taxonomica_join, -> { joins('LEFT JOIN categorias_taxonomicas ON categorias_taxonomicas.id=especies.categoria_taxonomica_id') }
  scope :adicional_join, -> { joins('LEFT JOIN adicionales ON adicionales.especie_id=especies.id') }
  scope :icono_join, -> { joins('LEFT JOIN iconos ON iconos.id=adicionales.icono_id') }

  # Select basico que contiene los campos a mostrar por ponNombreCientifico
  scope :select_basico, -> { select('especies.id, estatus, nombre_comun, nombre_cientifico, nombre_autoridad,
categoria_taxonomica_id, nombre_categoria_taxonomica,
adicionales.foto_principal, adicionales.nombre_comun_principal, iconos.taxon_icono, iconos.icono, iconos.nombre_icono, iconos.color_icono') }
    #categoria_taxonomica_id, nombre_categoria_taxonomica') }
  # select y joins basicos que contiene los campos a mostrar por ponNombreCientifico
  scope :datos_basicos, -> { select_basico.especies_join.categoria_taxonomica_join.adicional_join.icono_join }
  # Este select es para contar todas las especies partiendo del nombre comun
  scope :datos_count, -> { select('count(DISTINCT concat(especies.id, nombre_comun)) AS cuantos').especies_join }


  def species_or_lower?(cat, con_genero = false)
    if con_genero
      Especie::SPECIES_OR_LOWER.include?(cat) || Especie::BAJO_GENERO.include?(cat)
    else
      Especie::SPECIES_OR_LOWER.include?(cat)
    end
  end

  def completa_blurrily
    FUZZY_NOM_COM.put(nombre_comun, id)
  end

  def personalizaBusqueda
    "#{self.nombre_comun} (#{self.lengua})".html_safe
  end

  def exporta_redis(taxon)
    datos = {}
    datos['data'] = {}

    # Se unio estos identificadores para hacerlos unicos en la base de redis
    datos['id'] = "#{id}#{taxon.id}000".to_i

    # Para poder buscar con o sin acentos en redis
    datos['term'] = I18n.transliterate(nombre_comun.limpia)


    if ad = taxon.adicional
      if ad.foto_principal.present?
        datos['data']['foto'] = ad.foto_principal.limpia
      else
        datos['data']['foto'] = ''
      end

    else
      datos['data']['foto'] = ''
    end

    datos['data']['id'] = taxon.id
    datos['data']['nombre_cientifico'] = taxon.nombre_cientifico
    datos['data']['nombre_comun'] = nombre_comun.limpia
    datos['data']['estatus'] = Especie::ESTATUS_VALOR[taxon.estatus]
    datos['data']['autoridad'] = taxon.nombre_autoridad.limpia

    # Caracteristicas de riesgo y conservacion, ambiente y distribucion
    cons_amb_dist = []
    cons_amb_dist << taxon.nom_cites_iucn_ambiente_prioritaria
    cons_amb_dist << taxon.tipo_distribucion
    datos['data']['cons_amb_dist'] = cons_amb_dist.flatten

    # Para saber cuantas fotos tiene
    datos['data']['fotos'] = taxon.photos.count

    # Para saber si tiene algun mapa
    if p = taxon.proveedor
      datos['data']['geodatos'] = p.geodatos[:cuales]
    end

    # Para mandar el json como string al archivo
    datos.to_json.to_s
  end
end
