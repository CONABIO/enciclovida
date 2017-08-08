class ValidacionSimple < Validacion

  attr_accessor :lista, :lista_validada, :taxones

  COLUMNAS_OBLIGATORIAS = {nombre_cientifico: ['nombre_cientifico']}
  COLUMNAS_OPCIONALES = {}

  def initialize
    self.lista_validada = []
    self.taxones = []
    super
  end

  def valida_csv

  end

  def valida_txt

  end

  def valida_excel
    super

    sheet.parse(cabecera).each_with_index do |f, index|
      next if index == 0
      self.nombre_cientifico = f['nombre_cientifico']
      encuentra_por_nombre

      if validacion[:estatus]  # Encontro por lo menos un nombre cientifico valido
        self.excel_validado << asocia_respuesta
      else # No encontro coincidencia con nombre cientifico, probamos con los ancestros, a tratar de coincidir

      end  # info estatus inicial, con el nombre_cientifico original
    end  # sheet parse

    escribe_excel
    EnviaCorreo.excel(self).deliver if Rails.env.production?
  end

  def valida_lista
    return {estatus: false, msg: 'La lista no puede ser vacia.'} unless lista.present?

    self.lista = lista.split("\r\n")
    return {estatus: false, msg: 'Solo pueden ser 200 observaciones para validar en el área de texto, si requieres validar más por favor sube un archivo.'} if lista.length > 200

    lista.each do |nombre|
      self.nombre_cientifico = nombre
      encuentra_por_nombre

      self.lista_validada << validacion.merge({nombre_orig: nombre})
    end

    {estatus: true}
  end

  # Exporta la informacion, para que desde la lista guarde el excel
  def guarda_excel
    lista = Lista.new
    lista.columnas = %w(nombre_orig nombre_enciclovida mensaje) + Lista::COLUMNAS_GENERALES
    lista.taxones = lista_validada

    lista.to_excel(asignar: true)  # Para que asigne los valores de las columnas
  end
end