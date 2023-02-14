class Api::ConabioDgcc < Api::ConabioPlinian

  def initialize(opc = {})
    super(opc)
    self.servidor = servidor || CONFIG.site_url
  end

  def nombre
    'CONABIO (Resumen)'
  end

  private

  def buscar(q)

    #Para q pido la ficha en html y shalala si de todos modods la parseare con nokogiri?!!? WTF!
    ficha = Fichas::Taxon.where(IdCAT: q, tipoficha: 'DGCC').first

    return nil unless ficha
    solicita("fichas/front/#{ficha.especieId}/dgcc")
  end

end