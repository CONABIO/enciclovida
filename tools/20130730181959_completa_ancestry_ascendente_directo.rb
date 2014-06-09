class CompletaAncestryAscendenteDirecto < ActiveRecord::Migration
  def change
    Especie.all.each do |e|
      if !(e.id_nombre_ascendente.eql?(e.id))

        e.ancestry_acendente_directo="#{e.id_nombre_ascendente}"

        valor=true
        id=e.id_nombre_ascendente

        while valor do
          subEsp=Especie.find(id)

          if subEsp.id_nombre_ascendente.eql?(subEsp.id)
            valor=false

          else
            e.ancestry_acendente_directo="#{subEsp.id_nombre_ascendente}/#{e.ancestry_acendente_directo}"
            id=subEsp.id_nombre_ascendente
          end
        end

        e.save
      end

    end
  end
end
