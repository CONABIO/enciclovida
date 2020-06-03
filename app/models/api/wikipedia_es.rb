class Api::WikipediaEs < Api::Wikipedia

  def initialize(opc = {})
    self.locale = 'es'
    self.servidor = "http://#{locale}.wikipedia.org/w/api.php?redirects=true&action=parse&format=json"
    super(opc)
  end

  def nombre
    "Wikipedia (ES)"
  end

end