module Limpia
  #quita los saltos de linea de windows, escapa las dobles comillas y quita las identaciones
  def self.cadena(cad)
    cad.present? ? cad.gsub(/(\r\n|\r|\n)/, '').gsub('"', '\"').gsub("\t", ' ') : cad
  end
end

