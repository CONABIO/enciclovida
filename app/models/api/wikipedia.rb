class Api::Wikipedia < Api::Descripcion

  attr_accessor :locale
  DESCRIPCIONES = %w(wikipedia_es wikipedia_en)

  def initialize(opc = {})
    super(opc)
    self.locale = locale || opc[:locale] || I18n.locale || 'en'
    self.servidor = servidor || "http://#{locale}.wikipedia.org/w/api.php?redirects=true&action=parse&format=json"
  end

  def nombre
    "Wikipedia (#{locale.try(:upcase)})"
  end

  def dame_descripcion_cualquiera
    DESCRIPCIONES.each do |descripcion|
      desc = eval("Api::#{descripcion.camelize}")
      resp = desc.new(taxon: taxon).buscar
      return resp if resp
    end

    nil
  end

  def dame_descripcion
    begin
      buscar
    rescue => e
      Rails.logger.info "[INFO] Wikipedia API falló a intentar consutar el resumen: #{e.message}"
      return
    end
  end

  def resumen_cualquiera
    DESCRIPCIONES.each do |descripcion|
      desc = eval("Api::#{descripcion.camelize}")
      resp = desc.new(taxon: taxon).resumen
      return resp if resp
    end

    nil
  end

  def resumen
    begin
      resp = solicita

      hxml = Nokogiri::HTML(HTMLEntities.new.decode(resp))
      hxml.search('table').remove
      hxml.search("//comment()").remove
      res = ( hxml.search("//p").detect{|node| !node.inner_html.strip.blank?} || hxml ).inner_html.to_s.strip
      res = res.sanitize(tags: %w(p i em b strong))
      res.gsub! /\[.*?\]/, ''
      res

    rescue => e
      Rails.logger.info "[INFO] Wikipedia API falló a intentar consutar el resumen: #{e.message}" if debug
      return
    end
  end

  private

  def buscar
    resp = solicita
    limpia_html(resp)
  end

  def solicita
    begin
      uri = valida_uri
      resp = JSON.parse(open(uri).read)["parse"]["text"]["*"]
      return if resp.nil?
    rescue Timeout::Error => e
      Rails.logger.info "[INFO] Wikipedia API falló a intentar consutar el resumen: #{e.message}"
      return
    end

    resp
  end

  def valida_uri
    uri = URI.parse(URI.encode("#{servidor}&page=#{taxon.nombre_cientifico.limpiar.limpia}"))
    Rails.logger.debug "[DEBUG] Invocando URL: #{uri}" if debug

    uri
  end

  def limpia_html(html, options = {})
    coder = HTMLEntities.new
    html.gsub!(/(data-)?videopayload=".+?"/m, '')
    decoded = coder.decode(html)
    decoded.gsub!('href="//', 'href="http://')
    decoded.gsub!('src="//', 'src="http://')
    decoded.gsub!('href="/', 'href="http://en.wikipedia.org/')
    decoded.gsub!('src="/', 'src="http://en.wikipedia.org/')

    if options[:strip_references]
      decoded.gsub!(/<sup .*?class=.*?reference.*?>.+?<\/sup>/, '')
      decoded.gsub!(/<strong .*?class=.*?error.*?>.+?<\/strong>/, '')
    end

    decoded
  end

end