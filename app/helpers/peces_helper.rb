module PecesHelper
    def tituloNombreCientifico(taxon, params={})

      nombre = taxon.nombres_comunes.present? ? taxon.nombres_comunes.split(',').first : ''


        if params[:title]
          nombre.present? ? "#{nombre} (#{taxon.nombre_cientifico})".html_safe : taxon.nombre_cientifico
        elsif params[:link]
          nombre.present? ? "<h5>#{nombre}</h5><h5>#{link_to(ponItalicas(taxon).html_safe, especie_path(taxon))}</h5>" : "<h5>#{ponItalicas(taxon,true)}</h5>"
        elsif params[:show]
          nombre.present? ? "#{nombre} (#{ponItalicas(taxon)})".html_safe : ponItalicas(taxon).html_safe
        else
          'Ocurrio un error en el nombre'.html_safe
        end
    end
end
