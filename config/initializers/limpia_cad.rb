module Limpia
  def self.cadena(cad)
    cad.gsub(/(\r\n|\r|\n)/, '').gsub('"', "\"")                                    #quita los saltos de linea de windows y escapa las dosble comillas
  end
end
