class Api::ConabioTecnico < Api::Conabio

  def initialize(opc = {})
    super(opc)
    self.servidor = servidor || "http://#{IP}:#{PORT}"
  end

  def nombre
    'CONABIO (técnico)'
  end

  def dame_descripcion
    buscar
  end


  private

  def buscar
    solicita("especies/#{taxon.id}/descripcion_catalogos")
  end

end