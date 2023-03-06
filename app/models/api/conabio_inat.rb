class Api::ConabioInat < Api::Conabio

  DESCRIPCIONES = %w(conabio_plinian conabio_dgcc conabio_tecnico)

  def initialize(opc={})
    super(opc)
  end

  def nombre
    'CONABIO (Descripción para Naturalista)'
  end

  def dame_descripcion
    DESCRIPCIONES.each do |descripcion|
      desc = eval("Api::#{descripcion.camelize}")
      resp = desc.new(taxon: taxon).dame_descripcion
      return resp if resp
    end
    return "No existe descripción en CONABIO para el presente taxón."
  end

end