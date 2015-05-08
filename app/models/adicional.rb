class Adicional < ActiveRecord::Base
  belongs_to :especie

  GRUPOS_ICONICOS = {
      # Reino Animalia
      'Animalia' => %w(Animales icon-animales #6c3630),
      'Mammalia' => %w(Mamíferos icon-mamifero #9d4c47),
      'Aves' => %w(Aves icon-aves #9b7845),
      'Reptilia' => %w(Reptiles icon-reptil #999744),
      'Amphibia' => %w(Anfibios icon-anfibio #7a9944),
      'Actinopterygii' => ['Peces óseos', 'icon-peces', '#44997d'],
      'Petromyzontida' => %w(Lampreas icon-lampreas #449999),
      'Myxini' => %w(Mixines icon-mixines #437395),
      'Chondrichthyes' => ['Tiburones, rayas y quimeras', 'icon-tiburon_raya', '#284559'],
      'Cnidaria' => ['Medusas, corales y anémonas', 'icon-medusasc', '#56686f'],
      'Arachnida' => %w(Arácnidos icon-arana #6c4e30),
      'Myriapoda' => ['Ciempiés y milpies', 'icon-ciempies', '#7b5637'],
      'Annelida' => ['Lombrices y gusanos marinos', 'icon-lombrices', '#956e43'],
      'Insecta' => %w(Insectos icon-insectos #aa774d),
      'Porifera' => %w(Esponjas icon-porifera #a8734c),
      'Echinodermata' => ['Estrellas y erizos de mar', 'icon-estrellamar', '#865a3c'],
      'Mollusca' => ['Caracoles, almejas y pulpos', ' icon-caracol', '#aa7961'],
      'Crustacea' => %w(Crustáceos icon-crustaceo #a0837c),

      # Reino Plantae
      'Plantae' => %w(Plantas icon-plantas #3f7e54),
      'Bryophyta' => ['Musgos, hepáticas y antoceros', 'icon-musgo', '#7a7544'],
      'Pteridophyta' => %w(Helechos icon-helecho #adb280),
      'Cycadophyta' => %w(Cícadas icon-cicada #545a35),
      'Gnetophyta' => %w(Canutillos icon-canutillos #394822),
      'Liliopsida' => ['Pastos y palmeras', 'icon-pastos_palmeras', '#114722'],
      'Coniferophyta' => ['Pinos y cedros', 'icon-pino', '#788c4a'],
      'Magnoliopsida' => ['Margaritas y magnolias', 'icon-magnolias', '#495925'],

      # Reino Protoctista
      'Protoctista' => %w(Arquea icon-arquea #0c4354),

      # Reino Fungi
      'Fungi' => %w(Hongos icon-hongos #af7f45),

      # Reino Prokaryonte (desde 1930 ?)
      'Prokaryotae' => %w(Bacterias icon-bacterias #0e5f59)
  }

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

  def pon_grupo_iconico(grupo)
    datos_icono = GRUPOS_ICONICOS[grupo]
    self.icono = datos_icono[1]
    self.nombre_icono = datos_icono[0]
    self.color_icono = datos_icono[2]
  end
end