class ValidacionSimple < Validacion

  attr_accessor :lista, :lista_validada, :taxones

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
    return {estatus: false, obs: 'La lista no puede ser vacia.'} unless lista.present?

    self.lista = lista.split("\r\n")
    return {estatus: false, obs: 'Solo pueden ser 200 observaciones para validar en el área de texto, si requieres validar más por favor sube un archivo.'} if lista.length > 200

    lista.each do |nombre|
      self.nombre_cientifico = nombre
      encuentra_por_nombre

      self.lista_validada << validacion.merge({nombre_orig: nombre})

      # Para tener una lista de taxones y poder exportar esta lista a excel con el modelo Lista
      if validacion[:estatus]  # Encontro un único taxon
        self.taxones << validacion[:taxon]
      else  # Cuando el estatus es falso
        self.taxones << Especie.none
      end

    end  # End each

    {estatus: true}
  end
end