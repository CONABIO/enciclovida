class ValidacionSimple < Validacion

  attr_accessor :lista, :lista_validada

  # Si alguna columna se llama diferente, es solo cosa de añadir un elemento mas al array correspondiente
  COLUMNAS_OPCIONALES = {reino: ['reino'], division: ['division'], subdivision: ['subdivision'], clase: ['clase'], subclase: ['subclase'],
                         orden: ['orden'], suborden: ['suborden'], infraorden: ['infraorden'], superfamilia: ['superfamilia'],
                         subgenero: ['subgenero'], nombre_autoridad_infraespecie: %w(nombre_autoridad_infraespecie autoridad_infraespecie)}
  COLUMNAS_OBLIGATORIAS = {familia: ['familia'], genero: ['genero'], especie: ['especie'], nombre_autoridad: %w(nombre_autoridad autoridad),
                           infraespecie: ['infraespecie'], categoria_taxonomica: %w(categoria categoria_taxonomica), nombre_cientifico: ['nombre_cientifico']}

  def initialize
    self.lista_validada = []
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
    self.lista = lista.split(',')

    lista.each do |nombre|
      self.nombre_cientifico = nombre
      encuentra_por_nombre

      if validacion[:estatus]
        self.lista_validada << {nombre_orig: nombre, coincidencias: validacion[:taxon].nombre_cientifico, url: "#{CONFIG.enciclovida_url}/especies/#{validacion[:taxon].id}"}
      elsif validacion[:taxones].present?
        taxones = validacion[:taxones]
        nombres = taxones.map{|t| "#{CONFIG.enciclovida_url}/especies/#{t.id}"}
        urls = taxones.map{|t| t.nombre_cientifico}
        self.lista_validada << {nombre_orig: nombre, coincidencias: nombres.join(', '), url: urls.join(', ')}
      else
        self.lista_validada << {nombre_orig: nombre, coincidencias: validacion[:obs]}
      end

    end  # End each
  end
end