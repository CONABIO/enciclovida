class Api::WikipediaEn < Api::Wikipedia

  def initialize(opc = {})
    self.servidor = "https://en.wikipedia.org/w/api.php?redirects=true&action=parse&format=json"
    super(opc)
  end

  def nombre
    "Wikipedia (EN)"
  end

end