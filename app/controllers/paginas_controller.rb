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
    @select = {}
    @select[:grupos] = ['Anfibios', 'Aves', 'Hongos', 'Mamíferos', 'Peces', 'Plantas', 'Reptiles', 'Virus y bacterias']
    @select[:origenes] = ['Criptogénica', 'Exótica', 'Nativa']
    @select[:presencias] = ['Ausente', 'Confinado', 'Indeterminada', 'Por confirmar', 'Presente']
    #@select[:ambientes] = []  # Se necesita estandarizar
    @select[:estatus] = ['Invasora']

    @selected = {}
    if params[:grupo].present?
      @selected[:grupo] = {}
      @selected[:grupo][:valor] = params[:grupo]
      @selected[:grupo][:nom_campo] = 'OrdenfiloWEB'
    end

    if params[:origen].present?
      @selected[:origen] = {}
      @selected[:origen][:valor] = params[:origen]
      @selected[:origen][:nom_campo] = 'Origen'
    end

    if params[:presencia].present?
      @selected[:presencia] = {}
      @selected[:presencia][:valor] = params[:presencia]
      @selected[:presencia][:nom_campo] = 'Presencia'
    end

    if params[:estatus].present?
      @selected[:estatus] = {}
      @selected[:estatus][:valor] = params[:estatus]
      @selected[:estatus][:nom_campo] = 'Estatus'
    end

    file = File.dirname(__FILE__) << '/../../public/exoticas-invasoras.csv'
    exoticas_url = '/pdfs/exoticas_invasoras/'
    instrumentos_url = '/pdfs/exoticas_invasoras/instrumentos_legales/'
    exoticas_dir = File.dirname(__FILE__) << '/../../public' << exoticas_url
    inst_dir = File.dirname(__FILE__) << '/../../public' << instrumentos_url

    csv_text = File.read(file)
    csv = CSV.parse(csv_text, :headers => true)

    @por_pagina = 30
    @pagina = params[:pagina].present? ? params[:pagina].to_i : 1
    @totales = 0  # Cuenta los que han pasado el filtro

    csv.each_with_index do |row, index|
      siguiente = false
      @selected.each do |campo, v|  # Compara que las condiciones se cumplan
        siguiente = true if row[v[:nom_campo]] != v[:valor]
      end

      next if siguiente

      @totales+= 1
      next if (@por_pagina*(@pagina-1)+1) > @totales || @por_pagina*@pagina < @totales  # Por si esta fuera de rango del paginado

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
        # Para poner una foto de la carpeta, si es que tiene
        if row['Creditos Fotos'].present?
          nombre = "#{row['Nombre científico']}.jpg"
          foto = Rails.root.join('public','fotos_invasoras', nombre)

          if File.exists?(foto)
            foto_url = "/fotos_invasoras/#{nombre}"
            datos << foto_url
          else
            datos << nil
          end
        else
          datos << nil
        end

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
    @paginas = @totales%@por_pagina == 0 ? @totales/@por_pagina : (@totales/@por_pagina) +1
  end

end