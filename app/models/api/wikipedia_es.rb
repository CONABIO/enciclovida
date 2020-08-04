class Api::WikipediaEs < Api::Wikipedia

  def initialize(opc = {})
    self.servidor = "https://es.wikipedia.org/w/api.php?redirects=true&action=parse&format=json"
    super(opc)
  end

  def nombre
    "Wikipedia (ES)"
  end

end