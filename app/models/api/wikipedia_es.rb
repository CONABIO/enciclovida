class Api::WikipediaEs < Api::Wikipedia

  def initialize(opc = {})
    self.servidor = "http://es.wikipedia.org/w/api.php?redirects=true&action=parse&format=json"
    super(opc)
  end

  def nombre
    "Wikipedia (ES)"
  end

end