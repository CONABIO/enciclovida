class Api::Conabio < Api::Descripcion

  DESCRIPCIONES = %w(conabio_plinian conabio_xml conabio_tecnico)

  def initialize(opc={})
    super(opc)
  end

  def nombre
    'CONABIO (Descripción)'
  end

  def dame_descripcion
    DESCRIPCIONES.each do |descripcion|
      desc = eval("Api::#{descripcion.camelize}")
      resp = desc.new(taxon: taxon).dame_descripcion
      return resp if resp
    end
    #Sí no hay ficha en fespecies o la de xml  entonces regreso el nokogiri (iuu) de catálogos
    #solicita("especies/#{taxon.id}/descripcion_catalogos")
  end

end