# Este controlador tiene la finalidad de hacer contenido por paginas, ej la lista de invasoras
class PaginasController < ApplicationController
  skip_before_filter :set_locale

  def exoticas_invasoras
    @tabla_exoticas = {}
    @tabla_exoticas[:datos] = []
    file = File.dirname(__FILE__) << '/../../public/exoticas-invasoras.csv'
    exoticas_url = '/pdfs/exoticas_invasoras/'
    exoticas_dir = File.dirname(__FILE__) << '/../../public' << exoticas_url

    csv_text = File.read(file)
    csv = CSV.parse(csv_text, :headers => true)

    csv.each do |row|
      pdf = false
      datos = []

      if row['id_enciclovida'].present?
        t = Especie.find(row['id_enciclovida'])

        datos << t.adicional.try(:foto_principal)
        datos << t
        datos << (row['Nombre comun'].present? ? row['Nombre comun'] : t.adicional.try(:nombre_comun_principal))

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

    @tabla_exoticas[:cabeceras] = ['', 'Nombre científico', 'Nombre común', 'Familia', 'Ambiente',
                                   'Origen', 'Presencia', 'Estatus', 'Regulada por otros instrumentos', 'Ficha']
  end

end