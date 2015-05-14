class Adicional < ActiveRecord::Base
  belongs_to :especie
  belongs_to :icono

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
end