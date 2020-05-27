class Api::Conabio < Api::Descripcion

  DESCRIPCIONES = %w(conabio_plinian conabio_xml)

  def initialize(opc={})
    super(opc)
  end

  def nombre
    'CONABIO'
  end

  def dame_descripcion
    DESCRIPCIONES.each do |descripcion|
      desc = eval("Api::#{descripcion.camelize}")
      resp = desc.new(taxon: taxon).dame_descripcion
      return resp if resp
    end

    nil
  end

end