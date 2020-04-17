class Api::ConabioPlinian < Api::Descripcion

  def initialize(opc = {})
    super(opc)
    self.servidor = servidor || "http://#{IP}:#{PORT}"
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
    if Fichas::Taxon.where(IdCAT: q).first
      solicita("fichas/front/#{q}")
    else
      nil
    end
  end

end