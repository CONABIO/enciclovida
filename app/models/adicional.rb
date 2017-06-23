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
end