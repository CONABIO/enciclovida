class Api::ConabioPlinian < Api::Conabio

  def initialize(opc = {})
    super(opc)
    self.servidor = servidor || "https://#{IP}:#{PORT}"
  end

  def nombre
    'CONABIO (plinian core)'
  end

  def dame_descripcion
    return unless cat = taxon.scat
    buscar(cat.catalogo_id)
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