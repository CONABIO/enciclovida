# Este controlador tiene la finalidad de hacer contenido por paginas, ej la lista de invasoras
class PaginasController < ApplicationController
  skip_before_filter :set_locale
  layout false, :only => [:exoticas_invasoras_paginado]

  # La pagina cuando entran por get
  def exoticas_invasoras
    lee_csv
    @tabla_exoticas[:cabeceras] = ['', 'Nombre científico', 'Nombre común', 'Grupo', 'Familia', 'Ambiente',
                                   'Origen', 'Presencia', 'Estatus', 'Regulada por otros instrumentos', 'Ficha']
  end

  # La resultados que provienen del paginado
  def exoticas_invasoras_paginado
    lee_csv
    render partial: 'exoticas_invasoras'
  end

  protected

  def lee_csv
    @tabla_exoticas = {}
    @tabla_exoticas[:datos] = []
    file = File.dirname(__FILE__) << '/../../public/exoticas-invasoras.csv'
    exoticas_url = '/pdfs/exoticas_invasoras/'
    exoticas_dir = File.dirname(__FILE__) << '/../../public' << exoticas_url

    csv_text = File.read(file)
    csv = CSV.parse(csv_text, :headers => true)

    pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    por_pagina = 15#params[:por_pagina].present? ? params[:por_pagina].to_i : Busqueda::POR_PAGINA_PREDETERMINADO

    resultados = csv.count
    @paginas = resultados%por_pagina == 0 ? resultados/por_pagina : (resultados/por_pagina) +1

    csv.each_with_index do |row, index|
      next if (por_pagina*(pagina-1)) > index || ((por_pagina*pagina)-1) < index
      pdf = false
      datos = []

      if row['Enciclovida'].present?
        id = row['Enciclovida'].split('/')[4]
        t = Especie.find(id)

        datos << t.adicional.try(:foto_principal)
        datos << t
        datos << (row['Nombre comun'].present? ? row['Nombre comun'] : t.adicional.try(:nombre_comun_principal))
        datos << row['OrdenfiloWEB']

        if familia = t.ancestors.categoria_taxonomica_join.where("nombre_categoria_taxonomica = 'familia'")
          datos << familia.first.nombre_cientifico
        else
          datos << nil
        end

        pdf_path = exoticas_dir + t.nombre_cientifico + '.pdf'
        pdf = exoticas_url + t.nombre_cientifico + '.pdf' if File.exist?(pdf_path)

      else
        datos << nil
        datos << row['Nombre científico']
        datos << row['Nombre comun']
        datos << row['OrdenfiloWEB']
        datos << row['Familia']

        pdf_path = exoticas_dir + row['Nombre científico'] + '.pdf'
        pdf = exoticas_url + row['Nombre científico'] + '.pdf' if File.exist?(pdf_path)

      end  # End con id enciclovida

      datos << row['Ambiente']
      #datos << row['DistribuciónNativa']
      #datos << row['DistribuciónInvasora']
      datos << row['Origen']
      datos << row['Presencia']
      datos << row['Estatus']
      datos << row['Regulada por otros instrumentos']

      if pdf.present?
        datos << pdf
      else
        datos << nil
      end

      @tabla_exoticas[:datos] << datos

    end  # End each row
  end

end