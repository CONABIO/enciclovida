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
    @grupos = ['Anfibios', 'Aves', 'Hongos', 'Mamíferos', 'Peces', 'Plantas', 'Reptiles', 'Virus y bacterias']
    @grupo = params[:grupo] if params[:grupo].present? && @grupos.include?(params[:grupo])

    file = File.dirname(__FILE__) << '/../../public/exoticas-invasoras.csv'
    exoticas_url = '/pdfs/exoticas_invasoras/'
    instrumentos_url = '/pdfs/exoticas_invasoras/instrumentos_legales/'
    exoticas_dir = File.dirname(__FILE__) << '/../../public' << exoticas_url
    inst_dir = File.dirname(__FILE__) << '/../../public' << instrumentos_url

    csv_text = File.read(file)
    csv = CSV.parse(csv_text, :headers => true)

    por_pagina = 15000
    @pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    contador = 0  # Cuenta los que han pasado el filtro

    csv.each_with_index do |row, index|
      next if @grupo.present? && row['OrdenfiloWEB'] != @grupo  # Solo filtra los del grupo seleccionado

      contador+= 1
      next if (por_pagina*(@pagina-1)+1) > contador || por_pagina*@pagina < contador  # Por si esta fuera de rango del paginado

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

      instrumentos = []
      if row['Regulada por otros instrumentos'].present?
        row['Regulada por otros instrumentos'].split('/').each do |inst|
          inst = inst.strip
          pdf_inst_path = inst_dir + inst + '.pdf'
          if File.exist?(pdf_inst_path)
            pdf_inst = instrumentos_url + inst + '.pdf'
            instrumentos << {nombre: inst, pdf: pdf_inst}
          else  # Por si esta mal renombrado el pdf
            instrumentos << {nombre: 'No existe pdf', pdf: nil}
          end
        end  # End each do
      end

      datos << instrumentos
      pdf.present? ? datos << pdf : datos << nil

      @tabla_exoticas[:datos] << datos

    end  # End each row

    # El paginado
    resultados = contador
    @paginas = resultados%por_pagina == 0 ? resultados/por_pagina : (resultados/por_pagina) +1
  end

end