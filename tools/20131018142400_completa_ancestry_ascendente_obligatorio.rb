class CompletaAncestryAscendenteObligatorio < ActiveRecord::Migration
  def change
    Especie.all.each do |e|
      if !(e.id_ascend_obligatorio.eql?(e.id))

        e.ancestry_acendente_obligatorio="#{e.id_ascend_obligatorio}"

        valor=true
        id=e.id_ascend_obligatorio

        while valor do
          subEsp=Especie.find(id)

          if subEsp.id_ascend_obligatorio.eql?(subEsp.id)
            valor=false

          else
            e.ancestry_acendente_obligatorio="#{subEsp.id_ascend_obligatorio}/#{e.ancestry_acendente_obligatorio}"
            id=subEsp.id_ascend_obligatorio
          end
        end

        e.save
      end

    end
  end
end
