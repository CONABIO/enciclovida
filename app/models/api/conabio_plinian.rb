class Api::ConabioPlinian < Api::Conabio

  def initialize(opc = {})
    super(opc)
    self.servidor = servidor || CONFIG.site_url
  end

  def nombre
    'CONABIO (plinian core)'
  end

  def dame_descripcion
    return unless cat = taxon.scat
    resp = buscar(cat.catalogo_id)
    return resp if resp  # caso simple, fue el valido
    
    # Iteramos en los sinonimos
    resp = nil
    sinonimos = taxon.especies_estatus.sinonimos

    sinonimos.each do |sinonimo|
      next unless especie = sinonimo.especie 
      next unless cat = especie.scat
      resp = buscar(cat.catalogo_id)
      return resp if resp
    end

    resp  # Si llego aqui la respuesta es nula
  end


  private

  def buscar(q)
    if ficha = Fichas::Taxon.where(IdCAT: q).first
      if ficha.tipoficha == 'DGCC'
        solicita("fichas/front/#{q}/dgcc")
      else
        solicita("fichas/front/#{q}")  
      end
    else
      nil
    end
  end

end