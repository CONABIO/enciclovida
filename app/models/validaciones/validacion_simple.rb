class ValidacionSimple < Validacion

  attr_accessor :lista, :lista_validada

  def valida_campos
    super


  end
  
  def encuentra_por_nombre
    self.lista = lista.split(',')
    self.lista_validada = []

    lista.each do |nombre|
      self.nombre_cientifico = nombre
      super

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