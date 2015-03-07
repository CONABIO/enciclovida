class String
  # Pone en mayusculas o minusculas los acentos
  def humanizar
    self.humanize.mb_chars.capitalize.to_s
  end

  # Quita simbolos raros y quita los terminos con punto que estan abajo de especies y subgenero
  def limpiar
    return self unless self.present?
    self.limpia.gsub(/\([^()]*\)/, ' ').gsub(/( subsp\.| f\. | var\.| subf\.| subvar\.| sect\.)/, ' ').strip.gsub(/\s+/,' ')
  end

  # Quita simbolos raros
  def limpia
    return self unless self.present?
    self.gsub(/(\r\n|\r|\n)/, '').gsub('"', '\"').gsub("\t", ' ').strip.gsub(/\s+/,' ')
  end

  def limpia_csv
    return self unless self.present?
    self.gsub(/(\r\n|\r|\n)/, '').gsub('"', '""').gsub("\t", ' ').strip.gsub(/\s+/,' ')
  end
end

