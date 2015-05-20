class Adicional < ActiveRecord::Base
  belongs_to :especie
  belongs_to :icono

  attr_accessor :select_nom_comun, :text_nom_comun

  # Lenguas aceptadas de NaturaLista
  LENGUAS_ACEPTADAS = %w(spanish espanol_mexico huasteco maya maya_peninsular mayan_languages mazateco mixteco mixteco_de_yoloxochitl totonaco otomi nahuatl zapoteco english)

  def pon_nombre_comun_principal
    con_espaniol = false

    # Verifica el nombre en catalogos
    especie.nombres_comunes.each do |nc|
      if !con_espaniol && nc.lengua == 'Español'
        self.nombre_comun_principal = nc.nombre_comun.humanizar
        con_espaniol = true
      elsif !con_espaniol && nc.lengua == 'Inglés'
        self.nombre_comun_principal = nc.nombre_comun.humanizar
      elsif !con_espaniol
        self.nombre_comun_principal = nc.nombre_comun.humanizar
      end
    end

    # Si no tiene nombre comun en catalogos tratare de ponerle uno de NaturaLista
    if nombre_comun_principal.blank?
      return unless prov = especie.proveedor
      return unless prov.naturalista_info.present?

      datos = eval(prov.naturalista_info)
      datos = datos.first if datos.is_a?(Array)
      default_name = datos['default_name']

      return unless default_name.present?
      return unless default_name['is_valid']
      return unless default_name['name'].present?
      return unless default_name['lexicon'].present?

      lexicon = I18n.transliterate(default_name['lexicon']).gsub(' ','_').downcase
      return unless LENGUAS_ACEPTADAS.include?(lexicon)
      nombre_comun_principal = default_name['name']
      self.nombre_comun_principal = nombre_comun_principal.humanizar
    else
      self.nombre_comun_principal
    end
  end

  # Repito el metodo porque el otro, parte del modelo NombreComun, estos nombres son puestos
  # sin relacion a catalogos
  def exporta_nom_comun_a_redis
    data = ''
    data << "{\"id\":#{id}#{especie_id},"  #el ID de nombres_comunes no es unico (varios IDS repetidos)
    data << "\"term\":\"#{nombre_comun_principal.limpia}\","
    data << "\"data\":{\"nombre_cientifico\":\"#{especie.nombre_cientifico}\", "

    if icono
      data << "\"nombre_icono\":\"#{icono.nombre_icono}\", \"icono\":\"#{icono.icono}\", \"color\":\"#{icono.color_icono}\", "
    else
      data << "\"nombre_icono\":\"sin_icono\", \"icono\":\"icono\", \"color\":\"color_icono\", "
    end

    # Para diferenciar el campo que no saldra en el autocompletado de la vista avanzada
    data << "\"basica\":1, "
    data << "\"autoridad\":\"#{especie.nombre_autoridad.limpia}\", \"id\":#{especie.id}, \"estatus\":\"#{Especie::ESTATUS_VALOR[especie.estatus]}\"}"
    data << "}\n"
  end

  # Para exportar el nombre cientifico con el nombre comun principal pegado
  def exporta_nom_cien_a_redis
    return unless ad = adicional
    return unless ic = ad.icono

    data = ''
    data << "{\"id\":#{id},"
    data << "\"term\":\"#{nombre_cientifico}\","
    data << "\"data\":{\"nombre_comun\":\"#{ad.nombre_comun_principal.try(:limpia)}\", "
    data <<  "\"nombre_icono\":\"#{ic.nombre_icono}\", \"icono\":\"#{ic.icono}\", \"color\":\"#{ic.color_icono}\", "
    data << "\"autoridad\":\"#{nombre_autoridad.limpia}\", \"id\":#{id}, \"estatus\":\"#{Especie::ESTATUS_VALOR[estatus]}\"}"
    data << "}\n"
  end

  # Pone un nuevo record en redis para el nombre comun y el nombre cientifico
  def actualiza_o_crea_nom_com_en_redis
    fecha = Time.now.strftime("%Y%m%d%H%M%S")
    ruta_com = Rails.root.join('tmp','redis',"#{fecha}_#{id}-#{especie_id}_com.json").to_s
    ruta_cien = Rails.root.join('tmp','redis',"#{fecha}_#{id}-#{especie_id}_cien.json").to_s
    carpeta_redis = Rails.root.join('tmp','redis').to_s
    categoria = I18n.transliterate(especie.categoria_taxonomica.nombre_categoria_taxonomica).gsub(' ','_')
    json_com = exporta_nom_comun_a_redis
    json_cien = especie.exporta_redis
    Dir.mkdir(carpeta_redis, 0755) unless File.exists?(carpeta_redis)

    File.open(ruta_com,'a') do |f|
      f.puts(json_com)
    end

    File.open(ruta_cien,'a') do |f|
      f.puts(json_cien)
    end

    system("soulmate add com_#{categoria} --redis=redis://#{CONFIG.ip}:6379/0 < #{ruta_com}") if File.exists?(ruta_com)
    system("soulmate add cien_#{categoria} --redis=redis://#{CONFIG.ip}:6379/0 < #{ruta_cien}") if File.exists?(ruta_cien)
  end

  # Para borra el registro del nombre comun y actualiza el del nombre cientifico
  def borra_nom_comun_en_redis
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

    system("soulmate remove com_#{categoria} --redis=redis://#{CONFIG.ip}:6379/0 < #{ruta_com}") if File.exists?(ruta_com)
    system("soulmate add cien_#{categoria} --redis=redis://#{CONFIG.ip}:6379/0 < #{ruta_cien}") if File.exists?(ruta_cien)
  end
end