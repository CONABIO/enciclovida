class String
  # Pone en mayusculas o minusculas los acentos
  def humanizar
    self.humanize.mb_chars.capitalize.to_s
  end

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
end

