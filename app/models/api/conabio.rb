class Api::Conabio < Api::Descripcion

  DESCRIPCIONES = %w(conabio_plinian conabio_xml)

  def initialize(opc={})
    super(opc)
  end

  def nombre
    'CONABIO (Descripción)'
  end

def dame_descripcion
  DESCRIPCIONES.each do |descripcion|
    desc = eval("Api::#{descripcion.camelize}")
    resp = desc.new(taxon: taxon).dame_descripcion

    Rails.logger.debug "RESP de #{descripcion}: #{resp.inspect}"

    # Si es un objeto Nokogiri (CONABIO), limpiar solo tipografía
    if resp.is_a?(Nokogiri::HTML::Document)
      html_limpio = limpiar_tipografia_conabio(resp)
      return html_limpio if html_limpio.present?
    elsif resp.is_a?(String) && resp.present?
      return resp
    elsif resp.present?
      return resp.to_s
    end
  end

  "No existe descripción en CONABIO para el presente taxón."
end

def limpiar_tipografia_conabio(doc)
  # Clonar el documento para no modificar el original
  doc = doc.dup
  
  # 1. ELIMINAR ATRIBUTOS DE FUENTE Y ESTILO
  # Eliminar tags <font> pero mantener su contenido
  doc.css('font').each do |font|
    font.replace(font.children)
  end
  
  # Eliminar atributos style, face, size, etc.
  doc.css('*[style], *[face], *[size], *[lang]').each do |node|
    node.remove_attribute('style') if node['style']
    node.remove_attribute('face') if node['face']
    node.remove_attribute('size') if node['size']
    node.remove_attribute('lang') if node['lang']
    node.remove_attribute('class') if node['class'] && node['class'].include?('MsoNormal')
  end
  
  # 2. ESTANDARIZAR ETIQUETAS DE TEXTO
  # Convertir <span> sin atributos especiales a texto plano
  doc.css('span').each do |span|
    if span.attributes.empty? || (span.attributes.keys - ['class']).empty?
      span.replace(span.children)
    end
  end
  
  # 3. LIMPIAR ESPACIOS Y TEXTOS VACÍOS
  doc.traverse do |node|
    if node.text? && node.text.gsub(/\u00A0/, ' ').strip.empty?
      node.remove
    end
    
    # Reemplazar &nbsp; por espacio normal
    if node.text?
      node.content = node.content.gsub(/\u00A0/, ' ')
    end
  end
  
  # 4. ESTANDARIZAR ENCABEZADOS
  doc.css('h4, h5, h6').each do |header|
    # Eliminar clases de color
    header.remove_attribute('class') if header['class']
    # Asegurar que el texto esté limpio
    header.inner_html = header.text.strip
  end
  
  # 5. LIMPIAR PÁRRAFOS
  doc.css('p').each do |p|
    # Eliminar atributos
    p.attributes.each_key { |attr| p.remove_attribute(attr) }
    
    # Limpiar contenido
    p.inner_html = p.inner_html.gsub(/\s+/, ' ').strip
    
    # Eliminar párrafos vacíos
    p.remove if p.text.strip.empty?
  end
  
  # 6. ELIMINAR COMENTARIOS
  doc.xpath('//comment()').remove
  
  # 7. ELIMINAR SCRIPTS
  doc.css('script').remove
  
  # 8. EXTRAER SOLO EL CONTENIDO RELEVANTE (opcional - mantiene estructura)
  ficha = doc.at_css('div#ficha, div#clasiDescEsp')
  return ficha.to_html.html_safe if ficha
  
  # Si no encuentra la ficha específica, devolver el body limpio
  body = doc.at_css('body')
  body ? body.inner_html.html_safe : doc.to_html.html_safe
end

end