class String
  # Quita simbolos raros y quita los terminos con punto que estan abajo de especies y subgenero
  def limpiar(ssp = false)
    return self unless self.present?

    # Para poner ssp. como esta en NaturaLista y el Banco de Imagenes
    if ssp
      self.limpia.gsub(/\([^()]*\)/, ' ').gsub(/( f\. | var\. | subf\. | subvar\. )/, ' ').gsub(/ subsp\. /, ' ssp. ').strip.gsub(/\s+/,' ')
    else
      self.limpia.gsub(/\([^()]*\)/, ' ').gsub(/( subsp\. | f\. | var\. | subf\. | subvar\. )/, ' ').strip.gsub(/\s+/,' ')
    end
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

  # Escapa la comilla simple por dos comillas simples, para que SQL Server no marque error
  def limpia_sql
    self.gsub("'", "''")
  end

  def codifica64
    Base64.encode64(self)
  end

  def decodifica64
    return self.force_encoding('UTF-8') if self[0..1] != 'W3'
    decoded = Base64.decode64(self)
    decoded.force_encoding('UTF-8')
  end

  def primera_en_mayuscula
    self.sub(/^(.)/) { $1.mb_chars.capitalize }
  end
end

