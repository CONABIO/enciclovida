class Adicional < ActiveRecord::Base
  belongs_to :especie
  belongs_to :icono

  attr_accessor :select_nom_comun, :text_nom_comun

  # Lenguas aceptadas de NaturaLista
  LENGUAS_ACEPTADAS = %w(spanish espanol_mexico huasteco maya maya_peninsular mayan_languages mazateco mixteco mixteco_de_yoloxochitl totonaco otomi nahuatl zapoteco english)

  # El valido de catalogos
  def nombre_comun_principal_catalogos
    self.nombre_comun_principal = nil
    con_espaniol = false

    # Verifica el nombre en catalogos
    especie.nombres_comunes.each do |nc|
      if !con_espaniol && nc.lengua == 'Español'
        self.nombre_comun_principal = nc.nombre_comun
        con_espaniol = true
      elsif !con_espaniol && nc.lengua == 'Inglés'
        self.nombre_comun_principal = nc.nombre_comun
      elsif !con_espaniol
        self.nombre_comun_principal = nc.nombre_comun
      end
    end
  end

  def nombre_comun_principal_naturalista
    return unless prov = especie.proveedor
    return unless prov.naturalista_info.present?

    self.nombre_comun_principal = nil
    datos = eval(prov.naturalista_info.decodifica64)
    datos = datos.first if datos.is_a?(Array)
    default_name = datos['default_name']

    return unless default_name.present?
    return unless default_name['is_valid']
    return unless default_name['name'].present?
    return unless default_name['lexicon'].present?

    lexicon = I18n.transliterate(default_name['lexicon']).gsub(' ','_').downcase
    return unless LENGUAS_ACEPTADAS.include?(lexicon)
    nombre_comun_principal = default_name['name']
    self.nombre_comun_principal = nombre_comun_principal
  end

  def pon_nombre_comun_principal
    nombre_comun_principal_original = nombre_comun_principal
    self.nombre_comun_principal = nil

    nombre_comun_principal_naturalista

    # Si no tiene nombre comun NaturaLista pongo el de catalogos
    if nombre_comun_principal.blank?
      nombre_comun_principal_catalogos
    else
      self.nombre_comun_principal = nombre_comun_principal_original
    end
  end

  # Repito el metodo porque el otro, parte del nombre_cientifico, estos nombres son puestos
  def redis(opc={})
    taxon = especie
    datos = {}
    datos['data'] = {}

    # Se unio estos identificadores para hacerlos unicos en la base de redis
    datos['id'] = "#{id}#{especie_id}".to_i

    # Para poder buscar con o sin acentos en redis
    if nombre_comun_principal.present?
      datos['term'] = I18n.transliterate(nombre_comun_principal.limpia)
    else
      datos['term'] = ''
    end

    if foto_principal.present?
      datos['data']['foto'] = opc[:foto_principal].limpia || foto_principal.limpia
    else
      datos['data']['foto'] = ''
    end

    datos['data']['id'] = especie_id
    datos['data']['nombre_cientifico'] = taxon.nombre_cientifico
    datos['data']['nombre_comun'] = nombre_comun_principal.limpia
    datos['data']['estatus'] = Especie::ESTATUS_VALOR[taxon.estatus]
    datos['data']['autoridad'] = taxon.nombre_autoridad.limpia

    # Caracteristicas de riesgo y conservacion, ambiente y distribucion
    cons_amb_dist = []
    cons_amb_dist << taxon.nom_cites_iucn_ambiente_prioritaria
    cons_amb_dist << taxon.tipo_distribucion
    datos['data']['cons_amb_dist'] = cons_amb_dist.flatten

    # Para saber cuantas fotos tiene
    datos['data']['fotos'] = opc[:fotos_totales] || 0

    # Para saber si tiene algun mapa
    if p = taxon.proveedor
      datos['data']['geodatos'] = p.geodatos[:cuales]
    end

    datos
  end

  # Pone un nuevo record en redis para el nombre comun (fuera de catalogos) y el nombre cientifico
  def guarda_redis(opc={})
    return unless t = especie
    categoria = I18n.transliterate(t.categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')

    # Guarda en la categoria seleccionada
    loader = Soulmate::Loader.new(categoria)
    loader.add(redis(opc))
    #loader.add(t.redis(opc))
  end

  # Para borra el registro del nombre comun y actualiza el del nombre cientifico
  def borra_redis
    return unless especie

    fecha = Time.now.strftime("%Y%m%d%H%M%S")
    ruta_com = Rails.root.join('tmp','redis',"#{fecha}_#{id}-#{especie_id}_com.json").to_s
    ruta_cien = Rails.root.join('tmp','redis',"#{fecha}_#{id}-#{especie_id}_cien.json").to_s
    carpeta_redis = Rails.root.join('tmp','redis').to_s
    categoria = I18n.transliterate(especie.categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')
    json_com = "{\"id\":#{id}#{especie_id}}"
    json_cien = especie.exporta_redis
    Dir.mkdir(carpeta_redis, 0755) unless File.exists?(carpeta_redis)

    File.open(ruta_com,'a') do |f|
      f.puts(json_com)
    end

    File.open(ruta_cien,'a') do |f|
      f.puts(json_cien)
    end

    system("soulmate remove com_#{categoria} --redis=redis://#{IP}:6379/0 < #{ruta_com}") if File.exists?(ruta_com)
    system("soulmate add cien_#{categoria} --redis=redis://#{IP}:6379/0 < #{ruta_cien}") if File.exists?(ruta_cien)
  end
end