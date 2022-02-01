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
    ficha = jerarquia_fichas(q)
    return nil unless ficha

    if ficha.tipoficha == 'DGCC'
      solicita("fichas/front/#{ficha.especieId}/dgcc")
    else
      solicita("fichas/front/#{ficha.especieId}")  
    end
  end

  # cuando hay mas de una ficha en conabio
  def jerarquia_fichas(q)
    fichas = Fichas::Taxon.where(IdCAT: q)
    return nil unless fichas.any?

    resp = []
    fichas.each do |ficha|
      case ficha.tipoficha.downcase
        when 'prioritaria'
          resp[0] = ficha
        when 'invasora'
          resp[1] = ficha
        when 'cites'
          resp[2] = ficha
        when 'silvestre'
          resp[3] = ficha
        when 'dgcc'
          resp[4] = ficha
        else  # Ficha desconocida
          resp[5] = ficha
      end
    end  # end each do

    resp.compact.first
  end

end