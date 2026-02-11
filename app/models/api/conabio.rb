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

    # Limpiar tipografía si es CONABIO, manteniendo todo lo demás igual
    if resp.is_a?(Nokogiri::HTML::Document)
      resp = limpiar_tipografia_conabio(resp)
    end

    return resp if resp
  end

  "No existe descripción en CONABIO para el presente taxón."
end

def limpiar_tipografia_conabio(doc)
  doc = doc.dup
  
  # SOLO eliminar etiquetas font y atributos face
  doc.css('font').each do |font|
    font.replace(font.children)
  end
  
  doc.css('[face]').each do |node|
    node.remove_attribute('face')
  end
  
  # SOLO eliminar font-family de estilos inline
  doc.css('[style*="font-family"]').each do |node|
    style = node['style']
    style = style.gsub(/font-family\s*:\s*[^;]+;?/, '')
    
    if style.strip.empty?
      node.remove_attribute('style')
    else
      node['style'] = style
    end
  end
  
  # Mantener TODO lo demás exactamente igual
  doc.to_html.html_safe
end

end