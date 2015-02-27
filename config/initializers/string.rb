class String
  def humanizar
    self.humanize.mb_chars.capitalize.to_s
  end

  def limpiar
    return self unless self.present?
    self.gsub(/(\r\n|\r|\n)/, '').gsub('"', '\"').gsub("\t", ' ').gsub(/(\(|\))/, ' ').gsub(/( subsp\.| f\. | var\.)/, ' ').strip.gsub(/\s+/,' ')
  end
end

