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
    buscar
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

    rescue Timeout::Error => e
      Rails.logger.info "[INFO] Wikipedia API falló a intentar consutar el resumen: #{e.message}"
      return
    end
  end

  private

  def buscar
    begin
      resp = solicita
      html = limpia_html(resp)
    rescue Timeout::Error => e
      Rails.logger.debug "[INFO] Wikipedia API call failed: #{e.message}" if debug
    end

    html
  end

  def solicita
    begin
      uri = valida_uri
      begin
        resp = JSON.parse(open(uri).read)["parse"]["text"]["*"]
      rescue
        return
      end
      return if resp.nil?
    rescue Timeout::Error
      raise Timeout::Error, "#{nombre} no respondio en los primeros #{timeout} segundos."
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